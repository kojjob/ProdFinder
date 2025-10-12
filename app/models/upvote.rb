# frozen_string_literal: true

class Upvote < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - product_id (uuid, foreign key, indexed)
  # - user_id (uuid, foreign key, indexed)
  # - created_at (datetime, indexed)

  # Relationships
  belongs_to :product
  belongs_to :user

  # Validations
  validates :product_id, uniqueness: { scope: :user_id }
  # TODO: Add validation for user can't upvote own products
  # TODO: Add validation for can only upvote live products

  # Business Rules
  # - Upvotes contribute to daily, weekly, monthly rankings
  # - Early upvotes (first hour) weighted higher for rankings
  # - Can be removed within 24 hours
  # - Notifications sent to makers
end
