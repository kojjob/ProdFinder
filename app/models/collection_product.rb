# frozen_string_literal: true

class CollectionProduct < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - collection_id (uuid, foreign key, indexed)
  # - product_id (uuid, foreign key, indexed)
  # - position (integer, default: 0, for ordering)
  # - note (text, nullable, max 500 chars)
  # - added_at (datetime, default: current_timestamp)
  # - timestamps

  # Relationships
  belongs_to :collection, counter_cache: :products_count
  belongs_to :product

  # Validations
  validates :collection_id, uniqueness: { scope: :product_id, message: "already contains this product" }
  validates :note, length: { maximum: 500 }, allow_blank: true

  validate :product_must_be_live
  validate :collection_must_be_public_or_unlisted

  # Scopes
  scope :ordered, -> { order(position: :asc) }

  # Callbacks
  before_validation :set_default_position, on: :create

  # Business Rules
  # - Only live products can be added to collections
  # - Position determines display order
  # - Notes provide context for why product was added

  def set_default_position
    self.position ||= collection.collection_products.maximum(:position).to_i + 1
  end

  private

  def product_must_be_live
    if product && !product.live?
      errors.add(:product, "must be live to add to collection")
    end
  end

  def collection_must_be_public_or_unlisted
    if collection && collection.private?
      errors.add(:collection, "cannot add products to private collections")
    end
  end
end
