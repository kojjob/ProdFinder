class CategoriesController < ApplicationController
  before_action :set_category, only: [ :show ]

  def index
    @categories = Category.includes(:products).order(products_count: :desc)
  end

  def show
    @products = @category.products.includes(:maker, :topics, :upvotes).order(created_at: :desc).page(params[:page])
  end

  private

  def set_category
    @category = Category.includes(:products).find(params[:id])
  end
end
