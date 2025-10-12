# frozen_string_literal: true

class Comment < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - product_id (uuid, foreign key, indexed)
  # - user_id (uuid, foreign key, indexed)
  # - parent_id (uuid, foreign key, nullable, self-referential)
  # - body (text, required)
  # - upvotes_count (integer, default: 0, counter_cache)
  # - edited_at (datetime, nullable)
  # - deleted_at (datetime, nullable) # Soft delete
  # - timestamps

  # Relationships
  belongs_to :product
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :comment_upvotes, dependent: :destroy
  has_many :upvoters, through: :comment_upvotes, source: :user

  # Scopes
  default_scope -> { where(deleted_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Validations
  validates :body, presence: true, length: { minimum: 1, maximum: 5000 }
  # TODO: Add validation for max nesting depth: 3 levels
  # TODO: Add validation for can't comment on archived products

  # Business Rules
  # - Makers automatically get "Maker" badge on their comments
  # - Can edit within 15 minutes, shows "edited" indicator after
  # - Can delete own comments (soft delete)
  # - Notifications to product makers and thread participants
  # - Top comments determined by upvotes + recency algorithm
end
