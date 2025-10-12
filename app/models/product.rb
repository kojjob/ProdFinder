# frozen_string_literal: true

class Product < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - name (string, required, indexed)
  # - tagline (string, required, max: 100 chars)
  # - description (text, required)
  # - slug (string, unique, indexed)
  # - website_url (string, required, validated URL)
  # - launch_date (date, indexed)
  # - status (enum: draft, scheduled, live, archived)
  # - featured_at (datetime, nullable)
  # - product_of_day_at (date, nullable, indexed)
  # - pricing_type (enum: free, freemium, paid, subscription)
  # - africa_focused (boolean, default: true)
  # - countries_available (jsonb, array of country codes)
  # - maker_comment (text, nullable)
  # - upvotes_count (integer, default: 0, counter_cache)
  # - comments_count (integer, default: 0, counter_cache)
  # - views_count (integer, default: 0)
  # - maker_inside (boolean, default: false) # Maker is active in comments
  # - timestamps

  # Relationships
  has_many :product_makers
  has_many :makers, through: :product_makers, source: :user

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :tagline, presence: true, length: { minimum: 10, maximum: 100 }
  validates :description, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :website_url, presence: true # TODO: Add custom validator for URL format and reachability
  # TODO: Add validation for launch_date cannot be in past (for new products)
  # TODO: Add validation for status transitions

  # Enums
  enum status: { draft: 0, scheduled: 1, live: 2, archived: 3 }
  enum pricing_type: { free: 0, freemium: 1, paid: 2, subscription: 3 }

  # Business Rules
  # - Can only be edited by makers or hunters within 24hrs of launch (handled by authorization logic)
  # - Upvotes frozen after 7 days for "Product of Day" ranking (handled by a background job)
  # - Must have at least 1 maker and 1 media attachment to go live (handled by custom validation)
  # - Featured products manually selected by admins (handled by admin interface)
  # - Product of the Day selected based on upvotes in 24hr window (handled by a background job)
end
