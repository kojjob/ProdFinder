# frozen_string_literal: true

class BlogComment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  belongs_to :parent, class_name: "BlogComment", optional: true
  has_many :replies, class_name: "BlogComment", foreign_key: "parent_id", dependent: :destroy

  validates :content, presence: true, length: { minimum: 3, maximum: 2000 }
  validates :status, presence: true
  validate :post_must_be_published
  validate :parent_must_belong_to_same_post

  enum :status, { pending: 0, approved: 1, rejected: 2, spam: 3 }

  scope :approved, -> { where(status: :approved) }
  scope :by_post, ->(post) { where(post: post) }
  scope :recent, -> { approved.order(created_at: :desc) }
  scope :top_level, -> { where(parent_id: nil) }

  before_create :set_default_status
  after_create :increment_post_comments_count
  after_destroy :decrement_post_comments_count
  after_update :update_post_comments_count_on_status_change

  def self.ransackable_attributes(auth_object = nil)
    %w[content status user_id post_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user post parent]
  end

  def approved?
    status == "approved"
  end

  def pending?
    status == "pending"
  end

  def rejected?
    status == "rejected"
  end

  def spam?
    status == "spam"
  end

  def top_level?
    parent_id.nil?
  end

  def reply?
    parent_id.present?
  end

  def approve!
    update!(status: :approved)
  end

  def reject!
    update!(status: :rejected)
  end

  def mark_as_spam!
    update!(status: :spam)
  end

  def ancestors
    return [] if top_level?

    parent_ancestors = parent.ancestors
    parent_ancestors << parent
  end

  def descendants
    replies.flat_map { |reply| [ reply ] + reply.descendants }
  end

  def self_and_descendants
    [ self ] + descendants
  end

  def depth
    ancestors.size
  end

  def root_comment
    top_level? ? self : parent.root_comment
  end

  def thread_size
    1 + descendants.size
  end

  private

  def set_default_status
    self.status ||= :pending
  end

  def increment_post_comments_count
    post.increment!(:comments_count) if approved?
  end

  def decrement_post_comments_count
    post.decrement!(:comments_count) if approved?
  end

  def update_post_comments_count_on_status_change
    return unless saved_change_to_status?
    return unless post.present?

    old_status = saved_change_to_status[0]
    new_status = saved_change_to_status[1]

    # Handle status transitions that affect comments_count
    if old_status != "approved" && new_status == "approved"
      # Transition to approved - increment count
      Post.increment_counter(:comments_count, post.id)
    elsif old_status == "approved" && new_status != "approved"
      # Transition away from approved - decrement count
      Post.decrement_counter(:comments_count, post.id)
    end
  rescue => e
    # Log error but don't fail the update
    Rails.logger.error "Failed to update comments_count for post #{post.id}: #{e.message}"
  end

  def post_must_be_published
    return unless post.present?

    unless post.published?
      errors.add(:post, "must be published to receive comments")
    end
  end

  def parent_must_belong_to_same_post
    return unless parent.present? && post.present?

    unless parent.post_id == post_id
      errors.add(:parent, "must belong to the same post")
    end
  end
end
