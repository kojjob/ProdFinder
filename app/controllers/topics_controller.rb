class TopicsController < ApplicationController
  before_action :set_topic, only: [ :show ]

  def index
    @topics = Topic.includes(:products).order(products_count: :desc)
  end

  def show
    @products = @topic.products.includes(:maker, :upvotes, :comments).order(created_at: :desc).page(params[:page])
  end

  private

  def set_topic
    @topic = Topic.includes(:products).find(params[:id])
  end
end
