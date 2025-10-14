# Controller for managing product topics and browsing products by topic/tag
class TopicsController < ApplicationController
  before_action :set_topic, only: [ :show ]

  # GET /topics
  # Displays all topics ordered by product count (most popular first)
  # @return [Array<Topic>] topics with associated products count
  def index
    @topics = Topic.includes(:products).order(products_count: :desc)
  end

  # GET /topics/:id
  # Displays products within a specific topic with pagination
  # @return [Topic] the requested topic with its products
  # @return [Array<Product>] paginated products in the topic with associations
  def show
    @products = @topic.products.includes(:maker, :upvotes, :comments).order(created_at: :desc).page(params[:page])
  end

  private

  # Finds and sets the topic by ID with products association preloaded
  # @return [Topic] the found topic
  # @raise [ActiveRecord::RecordNotFound] if topic doesn't exist
  def set_topic
    @topic = Topic.includes(:products).find(params[:id])
  end
end
