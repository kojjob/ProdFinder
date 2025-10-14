# frozen_string_literal: true

class CommentUpvote < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - comment_id (uuid, foreign key, indexed)
  # - user_id (uuid, foreign key, indexed)
  # - created_at (datetime)

  # Relationships
  belongs_to :comment, counter_cache: true
  belongs_to :user

  # Validations
  validates :comment_id, uniqueness: { scope: :user_id, message: "already upvoted by this user" }

  validate :cannot_upvote_own_comment

  # Business Rules
  # - Contributes to comment ranking
  # - Visible to all users

  private

  def cannot_upvote_own_comment
    if comment && comment.user == user
      errors.add(:base, "Cannot upvote your own comment")
    end
  end
end
