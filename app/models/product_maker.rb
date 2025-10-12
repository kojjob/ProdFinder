# frozen_string_literal: true

class ProductMaker < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - product_id (uuid, foreign key, indexed)
  # - user_id (uuid, foreign key, indexed)
  # - role (enum: founder, co_founder, team_member)
  # - is_hunter (boolean, default: false) # Did they hunt vs make?
  # - position (integer, for ordering)
  # - timestamps

  # Relationships
  belongs_to :product
  belongs_to :user

  # Validations
  validates :product_id, uniqueness: { scope: :user_id }
  # TODO: Add validation for at least one founder per product
  # TODO: Add validation for hunter can't also be maker on same product

  # Enums
  enum role: { founder: 0, co_founder: 1, team_member: 2 }

  # Business Rules
  # - Founders get notifications for all product activity (handled by notification system)
  # - Only makers can edit product details (handled by authorization logic)
  # - Order matters for display (founders first) (handled by query scope)
end
