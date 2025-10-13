# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :author, polymorphic: true
  has_many :post_categories, dependent: :destroy
  has_many :categories, through: :post_categories
  has_many :blog_comments, dependent: :destroy
  has_many :seo_metadata, as: :seoable, dependent: :destroy
  has_many :sitemaps, as: :seoable, dependent: :destroy

  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :slug, presence: true, uniqueness: true, length: { maximum: 200 }
  validates :content, presence: true, length: { minimum: 50 }
  validates :excerpt, length: { maximum: 500 }
  validates :status, presence: true
  validates :meta_title, length: { maximum: 60 }
  validates :meta_description, length: { maximum: 160 }

  enum :status, { draft: 0, scheduled: 1, published: 2, archived: 3 }

  scope :published, -> { where(status: :published).where("published_at <= ?", Time.current) }
  scope :featured, -> { where(featured: true).where.not(featured_at: nil) }
  scope :recent, -> { published.order(published_at: :desc) }
  scope :popular, -> { published.order(views_count: :desc) }
  scope :by_category, ->(category) { joins(:categories).where(categories: { id: category }) }
  scope :by_author, ->(author) { where(author: author) }

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  before_validation :generate_excerpt, if: -> { excerpt.blank? && content.present? }
  before_validation :calculate_reading_time, if: -> { content.present? }
  before_validation :generate_meta_tags, if: -> { (meta_title.blank? || meta_description.blank?) && title.present? }
  before_save :update_published_at, if: -> { saved_change_to_status? && published? && published_at.blank? }

  def self.ransackable_attributes(auth_object = nil)
    %w[title content excerpt status author_type author_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[author categories]
  end

  def to_param
    slug
  end

  def published?
    status == "published" && published_at <= Time.current
  end

  def featured?
    featured? && featured_at.present?
  end

  def generate_slug
    base_slug = title.to_s.parameterize
    slug = base_slug.dup
    counter = 1

    while Post.exists?(slug: slug)
      slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug
  end

  def generate_excerpt
    self.excerpt = content.strip.gsub(/^(.{150}[^\s]*).*/m, '\1...')
  end

  def calculate_reading_time
    word_count = content.split.size
    self.reading_time = (word_count / 200.0).ceil # Assuming 200 words per minute
  end

  def generate_meta_tags
    self.meta_title ||= title
    self.meta_description ||= excerpt.present? ? excerpt.truncate(160) : content.truncate(160)
  end

  def update_published_at
    self.published_at = Time.current
  end

  def increment_views
    increment!(:views_count)
  end

  def mark_as_featured!
    update!(featured: true, featured_at: Time.current)
  end

  def remove_featured!
    update!(featured: false, featured_at: nil)
  end

  def related_posts(limit = 5)
    published.joins(:categories)
            .where(categories: { id: categories })
            .where.not(id: id)
            .distinct
            .limit(limit)
  end

  def popular_posts(limit = 5)
    published.where.not(id: id).order(views_count: :desc).limit(limit)
  end

  def tag_list
    tags.present? ? tags.split(",").map(&:strip) : []
  end

  def tag_list=(tags)
    self.tags = Array(tags).join(", ")
  end

  def has_tag?(tag)
    tag_list.include?(tag)
  end

  def word_count
    content.split.size
  end

  def estimated_reading_time
    reading_time || calculate_reading_time
  end

  def seo_score
    score = 0
    score += 20 if meta_title.present? && meta_title.length <= 60
    score += 20 if meta_description.present? && meta_description.length <= 160
    score += 15 if excerpt.present?
    score += 15 if featured_image.present?
    score += 15 if tags.present?
    score += 15 if content.length >= 300
    score
  end

  def featured_image
    # This would typically return the first image from content or a featured image field
    # For now, return nil or implement based on your content structure
    nil
  end

  def self.search(query)
    return none if query.blank?

    published.where(
      "title ILIKE ? OR content ILIKE ? OR excerpt ILIKE ?",
      "%#{query}%", "%#{query}%", "%#{query}%"
    )
  end

  def self.by_date_range(start_date, end_date)
    published.where(published_at: start_date..end_date)
  end

  def self.archive
    published
      .select("EXTRACT(YEAR FROM published_at) AS year, EXTRACT(MONTH FROM published_at) AS month, COUNT(*) AS count")
      .group("EXTRACT(YEAR FROM published_at)", "EXTRACT(MONTH FROM published_at)")
      .order("year DESC, month DESC")
  end
end
