class PagesController < ApplicationController
  before_action :authenticate_user!, only: []

  def home
    # Featured and recent products for showcase
    @featured_products = Product.live.featured.includes(:makers, :topics).limit(6)
    @recent_products = Product.live.includes(:makers, :topics).order(created_at: :desc).limit(8)

    # Stats for social proof
    @total_products = Product.live.count
    @total_makers = User.makers.count
    @total_upvotes = Product.live.sum(:upvotes_count)
    @countries_count = User.where.not(country_code: nil).distinct.count(:country_code)

    # Popular topics
    @popular_topics = Topic.where(featured: true).order(products_count: :desc).limit(6)
  end

  def community
    # Featured makers (top by reputation or followers)
    @featured_makers = User.where(maker_status: true)
                           .order(followers_count: :desc)
                           .limit(8)

    # Recent products for community showcase
    @recent_products = Product.where(status: :live)
                              .includes(:makers, :topics)
                              .order(created_at: :desc)
                              .limit(6)

    # Trending products (by upvotes in last 7 days)
    @trending_products = Product.where(status: :live)
                                .where('created_at >= ?', 7.days.ago)
                                .order(upvotes_count: :desc)
                                .limit(6)

    # Popular topics
    @popular_topics = Topic.where(featured: true)
                           .order(products_count: :desc)
                           .limit(12)

    # Community stats
    @total_products = Product.where(status: :live).count
    @total_makers = User.where(maker_status: true).count
    @total_upvotes = Product.where(status: :live).sum(:upvotes_count)
    @countries_count = User.where.not(country_code: nil).distinct.count(:country_code)
    @total_collections = Collection.where(visibility: :public).count

    # Recent activity (comments)
    @recent_comments = Comment.includes(:user, :product)
                              .order(created_at: :desc)
                              .limit(10)
  end

  def pricing
  end

  def maker_guide
  end

  def animations_demo
    # Demo page for showcasing all animations and micro-interactions
  end
end
