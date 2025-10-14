# frozen_string_literal: true

class Follow < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - follower_id (uuid, foreign key, indexed)
  # - follower_type (string, indexed)
  # - followee_id (uuid, foreign key, indexed)
  # - followee_type (string, indexed)
  # - timestamps

  # Relationships
  belongs_to :follower, polymorphic: true, counter_cache: :following_count
  belongs_to :followee, polymorphic: true, counter_cache: :followers_count

  # Validations
  validates :follower_id, uniqueness: {
    scope: [ :follower_type, :followee_id, :followee_type ],
    message: "already following this entity"
  }

  validate :cannot_follow_self
  validate :must_follow_same_type_or_user_to_topic

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :user_follows, -> { where(follower_type: "User", followee_type: "User") }
  scope :topic_follows, -> { where(follower_type: "User", followee_type: "Topic") }

  # Callbacks
  after_create :notify_followee

  # Business Rules
  # - Users can follow other users and topics
  # - Cannot follow yourself
  # - Follow relationships create notifications

  def user_follow?
    follower_type == "User" && followee_type == "User"
  end

  def topic_follow?
    follower_type == "User" && followee_type == "Topic"
  end

  private

  def cannot_follow_self
    if follower_id == followee_id && follower_type == followee_type
      errors.add(:base, "Cannot follow yourself")
    end
  end

  def must_follow_same_type_or_user_to_topic
    valid_combinations = [
      [ "User", "User" ],   # User follows User
      [ "User", "Topic" ]   # User follows Topic
    ]

    combination = [ follower_type, followee_type ]
    unless valid_combinations.include?(combination)
      errors.add(:base, "Invalid follow relationship")
    end
  end

  def notify_followee
    # TODO: Implement notification system
    # NotificationService.notify_follow(self) if user_follow?
  end
end
