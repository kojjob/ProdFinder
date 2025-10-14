# Controller for managing products in the ProdFinder platform
# Handles product creation, editing, viewing, and user-specific product listings
class ProductsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :my_products ]
  before_action :set_product, only: [ :show, :edit, :update ]

  # GET /products
  # Displays all live products with featured products and product of the day
  def index
    @products = Product.live.includes(:makers, :topics, :upvotes).order(created_at: :desc).page(params[:page])
    @featured_products = Product.live.featured.includes(:makers, :topics).limit(3)
    @product_of_day = Product.where(product_of_day_at: Date.current).includes(:makers, :topics).first
    @categories = Category.all
  end

  # GET /products/:id
  # Shows individual product with comments and comment form
  def show
    @comments = @product.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new if user_signed_in?
  end

  # GET /products/:id/quick_view
  # Shows product in a modal for quick preview
  # @return [turbo_stream] renders product modal
  def quick_view
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @product }
    end
  end

  # GET /products/new
  # Displays form for creating a new product
  def new
    @product = Product.new
  end

  # POST /products
  # Creates a new product with current user as maker
  def create
    # Ensure user is authenticated
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "You must be signed in to create a product."
      return
    end

    @product = Product.new(product_params)

    # Set status based on button clicked
    if params[:draft]
      @product.status = :draft
    else
      @product.status = :live
      @product.launch_date = Date.current
    end

    # Save the product first
    if @product.save
      # Add current user as a maker after product is saved
      unless @product.makers.include?(current_user)
        begin
          Rails.logger.info "Creating product maker for user #{current_user.id} and product #{@product.id}"
          @product.product_makers.create!(
            user: current_user,
            role: :founder,
            position: 0
          )
          Rails.logger.info "Successfully created product maker"
        rescue => e
          Rails.logger.error "Error creating product maker: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")

          # Try alternative approach with user_id directly
          begin
            @product.product_makers.create!(
              user_id: current_user.id,
              role: :founder,
              position: 0
            )
            Rails.logger.info "Successfully created product maker with user_id"
          rescue => e2
            Rails.logger.error "Failed both approaches: #{e2.message}"
            # Delete the product since we can't associate a maker
            @product.destroy
            redirect_to new_product_path, alert: "Failed to associate maker with product. Please try again."
            return
          end
        end
      end

      if @product.draft?
        redirect_to edit_product_path(@product), notice: "Product saved as draft. Continue editing when you're ready."
      else
        redirect_to @product, notice: "🎉 Congratulations! Your product has been launched successfully!"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /products/:id/edit
  # Displays form for editing an existing product
  def edit
  end

  # PATCH/PUT /products/:id
  # Updates an existing product, handling draft to live transitions
  def update
    # Handle status change from draft to live
    if @product.draft? && !params[:draft]
      @product.status = :live
      @product.launch_date = Date.current
    end

    if @product.update(product_params)
      if @product.draft?
        redirect_to edit_product_path(@product), notice: "Product draft updated successfully."
      else
        redirect_to @product, notice: "Product updated successfully."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /products/:id/toggle_upvote
  # Toggles upvote for the product using Hotwire Turbo
  # @return [turbo_stream] updates the upvote button without page reload
  def toggle_upvote
    @product = Product.find(params[:id])

    if current_user.upvoted?(@product)
      # Remove upvote if already upvoted
      @product.upvotes.where(user: current_user).destroy_all
      @upvoted = false
    else
      # Create upvote
      @product.upvotes.create(user: current_user)
      @upvoted = true
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @product }
    end
  end

  # GET /my_products
  # Shows products created by the current user
  def my_products
    @products = current_user.products.includes(:upvotes, :comments).order(created_at: :desc).page(params[:page])
  end

  private

  # Finds and sets the product with necessary associations
  def set_product
    @product = Product.includes(:makers, :topics, :upvotes, :comments).find(params[:id])
  end

  # Strong parameters for product creation and updates
  def product_params
    params.require(:product).permit(
      :name,
      :tagline,
      :description,
      :website_url,
      :pricing_type,
      :maker_comment,
      :africa_focused,
      topic_ids: []
    )
  end
end
