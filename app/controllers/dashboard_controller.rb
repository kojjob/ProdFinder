# Controller for user dashboard displaying personalized content and activity
class DashboardController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  # Displays user's personalized dashboard with their products, collections, and activity
  # @return [User] the current user
  # @return [Array<Product>] user's products ordered by creation date
  # @return [Array<Collection>] user's collections with products
  # @return [Array] recent activity for the user
  def index
    @user = current_user

    # Products - using the through association from product_makers
    @user_products = @user.products.includes(:makers, :topics).order(created_at: :desc)
    @recent_products = @user_products.limit(5)
    @live_products = @user.products.live
    @draft_products = @user.products.draft

    # Collections
    @user_collections = @user.collections.includes(:products).order(created_at: :desc)
    @recent_collections = @user_collections.limit(3)

    # Activity
    @recent_upvotes = @user.upvotes.includes(product: :makers).order(created_at: :desc).limit(10)
    @recent_comments = @user.comments.includes(:product).order(created_at: :desc).limit(10)
    @unread_notifications = @user.notifications.unread.order(created_at: :desc).limit(5)

    # Stats - using direct counts to avoid N+1
    @total_products = @user.products.count
    @live_products_count = @live_products.count
    @draft_products_count = @draft_products.count
    @total_upvotes_received = @user.products.sum(:upvotes_count)
    @total_comments_received = @user.products.sum(:comments_count)
    @total_views = @user.products.sum(:views_count)
    @total_followers = @user.followers_count
    @total_following = @user.following_count
    @total_collections = @user_collections.count
    @upvotes_given = @user.upvotes.count
    @comments_given = @user.comments.count

    # Trending/Top products (user's products with most recent activity)
    @trending_products = @user.products.live.order(upvotes_count: :desc, comments_count: :desc).limit(3)

    # Growth metrics (last 7 days) - using simpler approach to avoid type casting issues
    user_product_ids = @user.products.pluck(:id)
    @new_upvotes_this_week = if user_product_ids.any?
                               Upvote.where(product_id: user_product_ids)
                                     .where('upvotes.created_at >= ?', 7.days.ago).count
                             else
                               0
                             end
    @new_comments_this_week = if user_product_ids.any?
                                Comment.where(product_id: user_product_ids)
                                       .where('comments.created_at >= ?', 7.days.ago).count
                              else
                                0
                              end
    @new_followers_this_week = Follow.where(followee_type: 'User', followee_id: @user.id)
                                      .where('follows.created_at >= ?', 7.days.ago).count
  end

  private

  # Retrieves recent activity for the current user
  # TODO: Implement actual activity tracking (upvotes, comments, follows, etc.)
  # @return [Array] array of recent activity items (currently empty)
  def recent_activity_for_user
    # This would typically include user's product upvotes, comments, etc.
    # For now, return an empty array
    []
  end
end
