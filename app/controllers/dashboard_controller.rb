class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @user_products = @user.products.includes(:upvotes, :comments).order(created_at: :desc)
    @user_collections = @user.collections.includes(:products)
    @recent_activity = recent_activity_for_user
  end

  private

  def recent_activity_for_user
    # This would typically include user's product upvotes, comments, etc.
    # For now, return an empty array
    []
  end
end
