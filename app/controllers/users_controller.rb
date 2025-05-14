class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    # URL /users/:id
    @user = User.find(params[:id])
    # 自分以外のマイページを見せたくないなら：
    # redirect_to root_path unless @user == current_user
    head :not_found and return unless @user == current_user
    @reservations = @user.reservations.order(start_date: :desc)
  end
end