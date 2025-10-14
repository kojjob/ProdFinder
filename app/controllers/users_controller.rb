class UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :edit, :update ]
  before_action :set_user, only: [ :show, :edit, :update ]

  def show
    @products = @user.products.includes(:upvotes, :comments).order(created_at: :desc).page(params[:page])
    @collections = @user.collections.where(visibility: :public)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def products
    @products = @user.products.includes(:upvotes, :comments).order(created_at: :desc).page(params[:page])
    render :show
  end

  private

  def set_user
    return unless params[:id].match?(/\A\d+\z/)
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:full_name, :username, :bio, :website, :twitter, :github)
  end
end
