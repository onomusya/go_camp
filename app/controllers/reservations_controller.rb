class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @reservation = Reservation.new(
      start_date: params[:date],
      site_id: params[:site_id]
    )
  end

  def create
    @reservation = current_user.reservations.new(reservation_params)
    if @reservation.save
      redirect_to reservations_path, notice: "予約が完了しました。"
    else
      render :new, status: :unprocessable_entity
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
    params.require(:reservation).permit(:site_id, :start_date, :end_date)
  end
end
end
