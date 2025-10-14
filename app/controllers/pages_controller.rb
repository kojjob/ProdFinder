class PagesController < ApplicationController
  before_action :authenticate_user!, only: []

  def home
    @featured_products = Product.includes(:maker, :topics).limit(6)
    @recent_products = Product.includes(:maker, :topics).order(created_at: :desc).limit(8)
    @popular_categories = Category.includes(:products).order(products_count: :desc).limit(6)
  end

  def community
    @posts = Post.includes(:user, :comments).order(created_at: :desc).page(params[:page])
  end

  def pricing
  end

  def maker_guide
  end
end
