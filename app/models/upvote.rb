# frozen_string_literal: true

class Upvote < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - product_id (uuid, foreign key, indexed)
  # - user_id (uuid, foreign key, indexed)
  # - created_at (datetime, indexed)

  # Relationships
  belongs_to :product, counter_cache: true
  belongs_to :user, counter_cache: :upvotes_given_count

  # Validations
  validates :product_id, uniqueness: { scope: :user_id, message: "already upvoted by this user" }

  validate :cannot_upvote_own_product
  validate :can_only_upvote_live_products

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :today, -> { where("created_at >= ?", Time.current.beginning_of_day) }
  scope :this_week, -> { where("created_at >= ?", Time.current.beginning_of_week) }

  # Callbacks
  after_create :notify_makers
  after_create :update_user_reputation

  # Business Rules
  # - Upvotes contribute to daily, weekly, monthly rankings
  # - Early upvotes (first hour) weighted higher for rankings
  # - Can be removed within 24 hours
  # - Notifications sent to makers

  def can_be_removed?
    created_at > 24.hours.ago
  end

  def early_upvote?
    created_at <= 1.hour.after(product.created_at)
  end

  private

  def cannot_upvote_own_product
    if product && (product.user == user || product.makers.include?(user))
      errors.add(:base, "Cannot upvote your own product")
    end
  end

  def can_only_upvote_live_products
    if product && !product.live?
      errors.add(:base, "Can only upvote live products")
    end
  end

  def notify_makers
    # TODO: Implement notification system
    # product.makers.each { |maker| NotificationService.notify_upvote(maker, self) }
  end

  def update_user_reputation
    # TODO: Implement reputation system
    # user.increment!(:reputation_score, 1) if early_upvote?
  end
end
