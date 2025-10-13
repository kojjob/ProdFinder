# frozen_string_literal: true

class ProductTopic < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - product_id (uuid, foreign key, indexed)
  # - topic_id (uuid, foreign key, indexed)
  # - timestamps

  # Relationships
  belongs_to :product, counter_cache: false
  belongs_to :topic, counter_cache: :products_count

  # Validations
  validates :product_id, uniqueness: { scope: :topic_id, message: "already has this topic" }

  validate :max_topics_per_product
  validate :product_must_be_live

  # Business Rules
  # - Max 5 topics per product to maintain focus
  # - Only live products can have topics
  # - Topics help with product discovery and categorization

  private

  def max_topics_per_product
    if product && product.product_topics.count >= 5
      errors.add(:base, "Maximum 5 topics allowed per product")
    end
  end

  def product_must_be_live
    if product && !product.live?
      errors.add(:base, "Only live products can have topics")
    end
  end
end
