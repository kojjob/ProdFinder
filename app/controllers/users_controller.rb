# Controller for managing user profiles and profile-related actions
class UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :edit, :update ]
  before_action :set_user, only: [ :show, :edit, :update ]

  # GET /users/:id
  # Displays user profile with their products, upvotes, comments, collections, and stats
  # Supports both numeric IDs and usernames in the URL
  # @return [User] the requested user
  # @return [Array<Product>] user's recent products (limited to 12)
  # @return [Array<Product>] products upvoted by the user (limited to 12)
  # @return [Array<Comment>] user's recent comments (limited to 10)
  # @return [Array<Collection>] user's collections (limited to 6)
  # @return [Integer] various user statistics
  def show
    @products = @user.products.includes(:makers, :topics).order(created_at: :desc).limit(12)
    @upvoted_products = @user.upvoted_products.includes(:makers, :topics).limit(12)
    @recent_comments = @user.comments.includes(:product).order(created_at: :desc).limit(10)
    @collections = @user.collections.limit(6)

    # Stats
    @total_products = @user.products.count
    @total_upvotes_received = Upvote.where(product_id: @user.products.pluck(:id)).count
    @total_followers = 0 # @user.followers.count
    @total_following = 0 # @user.following.count
  end

  # GET /users/:id/edit
  # Displays form for editing user profile (owner only)
  # @return [User] the user to edit
  def edit
  end

  # PATCH/PUT /users/:id
  # Updates user profile including avatar management (owner only)
  # @return [User] the updated user on success
  # @return [User] the user with errors on failure
  def update
    # Handle avatar removal
    if params[:user][:remove_avatar] == "1"
      @user.avatar.purge
    end

    if @user.update(user_params)
      redirect_to @user, notice: "✨ Profile was successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # GET /users/:id/products
  # Displays paginated list of user's products
  # Reuses the show template with different data
  # @return [Array<Product>] paginated user products with associations
  def products
    @products = @user.products.includes(:upvotes, :comments).order(created_at: :desc).page(params[:page])
    render :show
  end

  private

  # Finds user by ID or username with flexible routing
  # Supports both numeric IDs and usernames for SEO-friendly URLs
  # @return [User] the found user
  # @raise [ActiveRecord::RecordNotFound] if user doesn't exist
  def set_user
    @user = if params[:id].match?(/\A\d+\z/)
              User.find(params[:id])
    else
              User.find_by!(username: params[:id])
    end
  end

  # Strong parameters for user profile updates
  # @return [ActionController::Parameters] permitted profile parameters
  def user_params
    params.require(:user).permit(:full_name, :username, :bio, :website_url, :twitter_handle, :github, :avatar)
  end
end
