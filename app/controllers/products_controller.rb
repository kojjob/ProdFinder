class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :my_products ]
  before_action :set_product, only: [ :show, :edit, :update ]

  def index
    @products = Product.includes(:maker, :topics, :upvotes).order(created_at: :desc).page(params[:page])
    @categories = Category.all
  end

  def show
    @comments = @product.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new if user_signed_in?
  end

  def new
    @product = Product.new
  end

  def create
    @product = current_user.products.build(product_params)

    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def my_products
    @products = current_user.products.includes(:upvotes, :comments).order(created_at: :desc).page(params[:page])
  end

  private

  def set_product
    @product = Product.includes(:maker, :topics, :upvotes, :comments).find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :url, :tagline, :logo, :screenshots, topic_ids: [])
  end
end
