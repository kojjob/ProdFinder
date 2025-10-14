# Controller for managing product categories and browsing products by category
class CategoriesController < ApplicationController
  before_action :set_category, only: [ :show ]

  # GET /categories
  # Displays all categories ordered by product count (most popular first)
  # @return [Array<Category>] categories with associated products count
  def index
    @categories = Category.includes(:products).order(products_count: :desc)
  end

  # GET /categories/:id
  # Displays products within a specific category with pagination
  # @return [Category] the requested category with its products
  # @return [Array<Product>] paginated products in the category with associations
  def show
    @products = @category.products.includes(:maker, :topics, :upvotes).order(created_at: :desc).page(params[:page])
  end

  private

  # Finds and sets the category by ID with products association preloaded
  # @return [Category] the found category
  # @raise [ActiveRecord::RecordNotFound] if category doesn't exist
  def set_category
    @category = Category.includes(:products).find(params[:id])
  end
end
