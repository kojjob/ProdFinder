# frozen_string_literal: true

class SeoMetadatum < ApplicationRecord
  belongs_to :seoable, polymorphic: true

  validates :title, length: { maximum: 60 }
  validates :description, length: { maximum: 160 }
  validates :keywords, length: { maximum: 255 }
  validates :og_title, length: { maximum: 100 }
  validates :og_description, length: { maximum: 300 }
  validates :twitter_title, length: { maximum: 100 }
  validates :twitter_description, length: { maximum: 280 }
  validates :robots, inclusion: { in: %w[index follow noindex nofollow none all] }, allow_blank: true

  before_validation :set_defaults_from_seoable
  before_validation :normalize_robots

  def self.for(seoable)
    find_or_initialize_by(seoable: seoable)
  end

  def meta_tags
    tags = {}
    tags[:title] = title if title.present?
    tags[:description] = description if description.present?
    tags[:keywords] = keywords if keywords.present?
    tags[:canonical] = canonical_url if canonical_url.present?
    tags[:robots] = robots if robots.present?
    tags
  end

  def og_tags
    tags = {}
    tags[:og_title] = og_title if og_title.present?
    tags[:og_description] = og_description if og_description.present?
    tags[:og_image] = og_image_url if og_image_url.present?
    tags
  end

  def twitter_tags
    tags = {}
    tags[:twitter_title] = twitter_title if twitter_title.present?
    tags[:twitter_description] = twitter_description if twitter_description.present?
    tags[:twitter_image] = twitter_image_url if twitter_image_url.present?
    tags[:twitter_card] = "summary_large_image"
    tags
  end

  def structured_data
    return {} unless json_ld.present?

    json_ld.is_a?(Hash) ? json_ld : JSON.parse(json_ld)
  rescue JSON::ParserError
    {}
  end

  def seo_score
    score = 0
    score += 20 if title.present? && title.length <= 60
    score += 20 if description.present? && description.length <= 160
    score += 15 if keywords.present?
    score += 15 if og_title.present? && og_image_url.present?
    score += 15 if twitter_title.present? && twitter_image_url.present?
    score += 15 if canonical_url.present?
    score
  end

  def complete?
    title.present? && description.present? && og_title.present? && og_image_url.present?
  end

  def generate_from_seoable
    return unless seoable.respond_to?(:title) && seoable.respond_to?(:description)

    self.title ||= seoable.title
    self.description ||= seoable.description
    self.og_title ||= seoable.title
    self.og_description ||= seoable.description
    self.canonical_url ||= seoable.respond_to?(:url) ? seoable.url : nil
  end

  private

  def set_defaults_from_seoable
    return unless seoable.present?

    generate_from_seoable if title.blank? || description.blank?
  end

  def normalize_robots
    self.robots = "index, follow" if robots.blank?
  end
end
