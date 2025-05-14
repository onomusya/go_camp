class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @site = Site.find(params[:site_id])
    @reservation = Reservation.new(
      site_id: @site.id,
      start_date: params[:start_date],
      end_date: (params[:start_date].to_date + 1.day),
      total_price: @site.price
    )
    # gon を new アクションでも設定
    gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
  end

  def create
    reservation_attributes = params.require(:reservation).permit(:site_id, :start_date, :end_date, :total_price)

    # トークンを params から別途取得
    payjp_token = params[:token]

    # Reservation オブジェクトを生成 (トークンを含めない)
    @reservation = current_user.reservations.new(reservation_attributes)
    # total_price が params から来ていない場合などの計算ロジックを呼び出し
    @reservation.calculate_total_price # このメソッドがReservationモデルに定義されている必要があります

    # サイト情報を再度取得（エラーでrender :new する場合に備えて）
    @site = @reservation.site

    # 予約のバリデーションを実行
    if @reservation.valid?
      # バリデーションに成功したら、決済処理に進む
      # ただし、トークンがない場合は決済に進めない
      if payjp_token.present?
        begin
          # 決済実行メソッドを呼び出し、トークンと金額を渡す
          pay_reservation(payjp_token, @reservation.total_price)

          # 決済成功後、予約を保存
          if @reservation.save
            redirect_to reservations_path, notice: '予約が完了しました。'
          else
            # 予約の保存自体に失敗した場合（決済は成功したがDBエラーなど）
            # これは稀なケースですが、ロールバックや補償処理が必要になる場合があります
            flash.now[:alert] = "決済は完了しましたが、予約情報の保存に失敗しました。サイト管理者にお問い合わせください。"
            # render :new するので gon を設定
            gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
            render :new, status: :unprocessable_entity
          end

        rescue Payjp::APIError => e
          # 決済失敗時
          # 予約を保存しない、または保存済みの場合は削除/状態変更など
          # @reservation.destroy # 例: 予約を削除 (予約保存前に決済する場合)
          flash.now[:alert] = "決済処理に失敗しました。カード情報をご確認ください。（エラーコード: #{e.code}）"
          # render :new するので gon を設定
          gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
          render :new, status: :unprocessable_entity # 入力フォームに戻る
        rescue => e # その他の予期せぬエラー
          flash.now[:alert] = "予約処理中に予期せぬエラーが発生しました。"
          # render :new するので gon を設定
          gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
          render :new, status: :unprocessable_entity
        end
      else
        # トークンがクライアントから送られてこなかった場合
        flash.now[:alert] = "決済情報が正しく送信されませんでした。再度お試しください。"
        # render :new するので gon を設定
        gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
        render :new, status: :unprocessable_entity # 入力フォームに戻る
      end
    else
      # 予約のバリデーションに失敗した場合
      flash.now[:alert] = "予約内容に不備があります。ご確認ください。" # バリデーションエラーメッセージを表示する場合はこちらを調整
      # render :new するので gon を設定
      gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
      render :new, status: :unprocessable_entity # 入力フォームに戻る
    end
  end

  def index
    gon.public_key = ENV["PAYJP_PUBLIC_KEY"]
    @reservations = current_user.reservations.includes(:site).order(start_date: :asc)
  end

  def destroy
    @reservation = current_user.reservations.find(params[:id])
    @reservation.destroy
    redirect_to reservations_path, notice: "予約をキャンセルしました。"
  end

  private

  def reservation_params
    params.require(:reservation).permit(:site_id, :start_date, :end_date, :total_price)
  end

  # 決済処理メソッド：引数でトークンと金額を受け取る
  def pay_reservation(token, amount)
    Payjp.api_key = ENV["PAYJP_SECRET_KEY"]
    # Payjp::Charge.create の card パラメータに引数で受け取った token を渡す
    Payjp::Charge.create(
      amount: amount,
      card: token,
      currency: 'jpy'
    )
  end
end
