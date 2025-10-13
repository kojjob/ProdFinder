# frozen_string_literal: true

class TopicFollow < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - user_id (uuid, foreign key, indexed)
  # - topic_id (uuid, foreign key, indexed)
  # - timestamps

  # Relationships
  belongs_to :user
  belongs_to :topic, counter_cache: :followers_count

  # Validations
  validates :user_id, uniqueness: { scope: :topic_id, message: "already following this topic" }

  # Business Rules
  # - Users follow topics to get notified of new products
  # - Topic follows help with product discovery
  # - No limit on topic follows per user
end
