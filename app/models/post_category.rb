# frozen_string_literal: true

class PostCategory < ApplicationRecord
  belongs_to :post
  belongs_to :category

  validates :post_id, uniqueness: { scope: :category_id }
  validate :post_must_be_published, on: :create

  private

  def post_must_be_published
    return unless post.present?

    unless post.published?
      errors.add(:post, "must be published to be categorized")
    end
  end
end
