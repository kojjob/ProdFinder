# frozen_string_literal: true

class Medium < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - product_id (uuid, foreign key, indexed)
  # - media_type (enum: image, video, gif)
  # - file_url (string, required) # Active Storage or CDN
  # - thumbnail_url (string, nullable)
  # - position (integer, for ordering)
  # - alt_text (string, nullable)
  # - is_thumbnail (boolean, default: false)
  # - timestamps

  # Relationships
  belongs_to :product

  # Enums
  enum media_type: { image: 0, video: 1, gif: 2 }

  # Validations
  validates :file_url, presence: true
  validates :media_type, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  # TODO: Add validation for exactly one is_thumbnail per product
  # TODO: Add validation for max 10 media items per product
  # TODO: Add validation for supported formats

  # Business Rules
  # - First image is default thumbnail unless specified
  # - Videos max 30 seconds
  # - Images optimized for web (<2MB)
end
