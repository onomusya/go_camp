class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_site,      only: [:new, :create]
  before_action :set_gon_key,   only: [:new, :create, :index]

  def new
    @reservation = current_user.reservations.new(
      site:       @site,
      start_date: params[:start_date],
      end_date:   params[:start_date].to_date + 1.day
    )
  end

  def create
    permitted_params = reservation_params
  
    @reservation = current_user.reservations.new(permitted_params.except(:rental_item_ids).merge(site: @site))
  
    rental_item_quantities = permitted_params[:rental_item_ids] || {}
  
    # 選択されたアイテムを中間テーブル（ReservationItem）用に組み立て
    build_reservation_items(rental_item_quantities)
  
    # ここで予約全体のバリデーションを実行
    if @reservation.valid?
      # バリデーションに成功したら、合計金額を計算する
      calculate_total_price # <--- Call calculate_total_price HERE!
  
      # 合計金額が計算されたら、決済処理に進む
      if process_payment_and_save
        redirect_to reservation_complete_path
      else
        # 決済失敗時 (flash.now[:alert] は process_payment_and_save で設定済み)
        render :new, status: :unprocessable_entity
      end
    else
      # 予約のバリデーションに失敗した場合 (total_price 計算前でも、他の項目で失敗する可能性あり)
      flash.now[:alert] = '予約内容に不備があります。ご確認ください。'
      # build_reservation_items で items が既に populate されているはずなので、render :new でフォームに反映されるはず
      render :new, status: :unprocessable_entity
    end
  end

  def complete
  end

  def index
    @reservations = current_user.reservations.includes(:site).order(start_date: :asc)
  end

  def destroy
    @reservation = current_user.reservations.find(params[:id])
    @reservation.destroy
    redirect_to reservations_path, notice: '予約をキャンセルしました。'
  end


  private

  # new/create で使うサイト情報をセット
  def set_site
    @site = Site.find(params[:site_id] || reservation_params[:site_id])
  end

  # Pay.jp 公開鍵をクライアントへ渡す
  def set_gon_key
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    gon.site_price = @site.price if defined?(@site) && @site.present?
  end

  # DB保存用のパラメータのみ許可
  # rental_item_ids をハッシュとして許可するように修正
  def reservation_params
    params.require(:reservation).permit(:site_id, :start_date, :end_date, rental_item_ids: {})
    # rental_item_ids: {} は、rental_item_ids というキーに対応する値がハッシュであり、
    # そのハッシュ内の任意のキー（アイテムID）と値（数量）を許可するという意味です。
  end

  # 選択されたアイテムを中間テーブル用に組み立て
  def build_reservation_items(quantities)
    # quantities を Hash に変換してから flat_map を呼び出す ★修正箇所★
    @reservation.reservation_items = quantities.to_h.flat_map do |item_id, qty_str|
      qty = qty_str.to_i
      next [] if qty <= 0

      # Item を取得して関連付け
      item = Item.find_by(id: item_id)
      next [] unless item # アイテムが見つからない場合はスキップ

      # ReservationItem オブジェクトを数量分生成し、@reservation に関連付けながらビルド
      # ReservationItem モデルに belongs_to :item があり、belongs_to :reservation がある前提
      Array.new(qty) { @reservation.reservation_items.build(item: item) }
      # Alternative if ReservationItem only takes item_id:
      # Array.new(qty) { @reservation.reservation_items.build(item_id: item.id) }
    end
  end

  # サイト料金＋アイテム料金を合算して total_price にセット
  def calculate_total_price
    base       = @site.price
    items_total = @reservation.reservation_items.sum { |ri| ri.item.price }
    @reservation.total_price = base + items_total
  end

  # 決済（Pay.jp）→ DB 保存までの一連処理
  def process_payment_and_save
    token = params[:token]
    return false unless token.present?
  
    # total_price がセットされているか、念のため確認しても良い
    # return false unless @reservation.total_price.present? && @reservation.total_price > 0
  
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    begin
      # Payjp charge will now use the calculated @reservation.total_price
      charge = Payjp::Charge.create(
        amount: @reservation.total_price,
        card: token,
        currency: 'jpy'
      )
      # Payjpのcharge_idなどを reservation に保存したい場合はここでセット
      # @reservation.payjp_charge_id = charge.id if @reservation.respond_to?(:payjp_charge_id=)
  
      # 決済が成功したらDBに保存
      @reservation.save
    rescue Payjp::PayjpError => e
      flash.now[:alert] = "決済エラー：#{e.message}"
      false # 決済エラー時は保存せず false を返す
    rescue => e # Payjpエラー以外の例外（例: 保存時のバリデーションエラーなど）も捕捉
       flash.now[:alert] = "予約の保存中に予期せぬエラーが発生しました: #{e.message}"
       false # その他のエラー時も保存せず false を返す
    end
  end
end