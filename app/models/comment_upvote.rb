# frozen_string_literal: true

class CommentUpvote < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - comment_id (uuid, foreign key, indexed)
  # - user_id (uuid, foreign key, indexed)
  # - created_at (datetime)

  # Relationships
  belongs_to :comment
  belongs_to :user

  # Validations
  validates :comment_id, uniqueness: { scope: :user_id }
  # TODO: Add validation for can't upvote own comments

  # Business Rules
  # - Contributes to comment ranking
  # - Visible to all users
end
