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
  belongs_to :product, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id", dependent: :destroy
  has_many :comment_upvotes, dependent: :destroy
  has_many :upvoters, through: :comment_upvotes, source: :user

  # Scopes
  default_scope -> { where(deleted_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :top_comments, -> { order(upvotes_count: :desc, created_at: :desc) }
  scope :root_comments, -> { where(parent_id: nil) }

  # Validations
  validates :body, presence: true, length: { minimum: 1, maximum: 5000 }

  validate :max_nesting_depth
  validate :cannot_comment_on_archived_product

  # Callbacks
  after_create :mark_product_maker_inside
  after_create :notify_participants

  # Business Rules
  # - Makers automatically get "Maker" badge on their comments
  # - Can edit within 15 minutes, shows "edited" indicator after
  # - Can delete own comments (soft delete)
  # - Notifications to product makers and thread participants
  # - Top comments determined by upvotes + recency algorithm

  def edited?
    edited_at.present?
  end

  def deleted?
    deleted_at.present?
  end

  def soft_delete!
    update!(deleted_at: Time.current, body: "[deleted]")
  end

  def can_edit?(current_user)
    return false unless current_user
    return false if deleted?
    user == current_user && created_at > 15.minutes.ago
  end

  def can_delete?(current_user)
    return false unless current_user
    user == current_user || current_user.admin?
  end

  def maker_comment?
    product.makers.include?(user)
  end

  def nesting_level
    return 0 if parent_id.nil?

    level = 0
    comment = self
    while comment.parent.present?
      level += 1
      comment = comment.parent
    end
    level
  end

  private

  def max_nesting_depth
    if parent && parent.nesting_level >= 2
      errors.add(:parent, "Maximum nesting depth of 3 levels exceeded")
    end
  end

  def cannot_comment_on_archived_product
    if product&.archived?
      errors.add(:base, "Cannot comment on archived products")
    end
  end

  def mark_product_maker_inside
    if maker_comment?
      product.update!(maker_inside: true) unless product.maker_inside?
    end
  end

  def notify_participants
    # TODO: Implement notification system
    # NotificationService.notify_comment(self)
  end
end
