class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @site = Site.find(params[:site_id])  # サイトIDでSiteを取得
    @reservation = Reservation.new(
      site_id: @site.id,
      start_date: params[:start_date],
      end_date: (params[:start_date].to_date + 1.day), # デフォルトで1日後
      total_price: @site.price  # 価格を予約に渡す
    )
  end

  def create
    @reservation = current_user.reservations.new(reservation_params)
    @reservation.calculate_total_price
    @site = @reservation.site

    if @reservation.save
      redirect_to reservations_path, notice: '予約が完了しました。'
    else
      render :new
    end
  end

  def index
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
end

