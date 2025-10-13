# frozen_string_literal: true

class Notification < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - user_id (uuid, foreign key, indexed)
  # - actor_id (uuid, foreign key, indexed, nullable)
  # - notifiable_type (string, indexed)
  # - notifiable_id (uuid, indexed)
  # - notification_type (enum, required)
  # - title (string, required)
  # - body (text, nullable)
  # - action_url (string, nullable)
  # - read_at (datetime, nullable)
  # - email_sent_at (datetime, nullable)
  # - timestamps

  # Enums
  enum :notification_type, {
    upvote: 0,
    comment: 1,
    mention: 2,
    follow: 3,
    product_featured: 4,
    milestone: 5,
    product_of_day: 6,
    reply: 7,
    collection_add: 8
  }

  # Relationships
  belongs_to :user
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  # Validations
  validates :notification_type, presence: true
  validates :title, presence: true

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }

  # Business Rules
  # - Notifications inform users of relevant activity
  # - Unread count shown in UI
  # - Email notifications sent based on user preferences

  def mark_as_read!
    update!(read_at: Time.current) if read_at.nil?
  end

  def unread?
    read_at.nil?
  end

  def read?
    !unread?
  end

  def email_sent?
    email_sent_at.present?
  end
end
