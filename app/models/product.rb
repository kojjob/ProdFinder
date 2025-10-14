# frozen_string_literal: true

class Product < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - name (string, required, indexed)
  # - tagline (string, required, max: 100 chars)
  # - description (text, required)
  # - slug (string, unique, indexed)
  # - website_url (string, required, validated URL)
  # - launch_date (date, indexed)
  # - status (enum: draft, scheduled, live, archived)
  # - featured_at (datetime, nullable)
  # - product_of_day_at (date, nullable, indexed)
  # - pricing_type (enum: free, freemium, paid, subscription)
  # - africa_focused (boolean, default: true)
  # - countries_available (jsonb, array of country codes)
  # - maker_comment (text, nullable)
  # - upvotes_count (integer, default: 0, counter_cache)
  # - comments_count (integer, default: 0, counter_cache)
  # - views_count (integer, default: 0)
  # - maker_inside (boolean, default: false) # Maker is active in comments
  # - timestamps

  # Relationships
  has_many :product_makers, dependent: :destroy
  has_many :makers, through: :product_makers, source: :user
  has_many :media, dependent: :destroy
  has_many :upvotes, dependent: :destroy
  has_many :upvoters, through: :upvotes, source: :user
  has_many :comments, dependent: :destroy
  has_many :commenters, through: :comments, source: :user
  has_many :product_topics, dependent: :destroy
  has_many :topics, through: :product_topics
  has_many :collection_products, dependent: :destroy
  has_many :collections, through: :collection_products
  belongs_to :user, optional: true

  # Relationships - SEO
  has_many :seo_metadata, as: :seoable, dependent: :destroy
  has_many :sitemaps, as: :seoable, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :tagline, presence: true, length: { minimum: 10, maximum: 100 }
  validates :description, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :website_url, presence: true, format: { with: URI.regexp(%w[http https]), message: "must be a valid URL" }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }

  # Custom validations
  validate :must_have_at_least_one_maker, on: :update
  validate :must_have_valid_makers
  # TODO: Add validation for launch_date cannot be in past (for new products)
  # TODO: Add validation for status transitions

  # Enums
  enum :status, { draft: 0, scheduled: 1, live: 2, archived: 3 }
  enum :pricing_type, { free: 0, freemium: 1, paid: 2, subscription: 3 }

  # Scopes
  scope :live, -> { where(status: :live) }
  scope :draft, -> { where(status: :draft) }
  scope :featured, -> { where.not(featured_at: nil) }
  scope :product_of_day, -> { where.not(product_of_day_at: nil) }
  scope :by_upvotes, -> { order(upvotes_count: :desc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :launching_today, -> { where(launch_date: Date.current) }
  scope :africa_focused, -> { where(africa_focused: true) }
  scope :free_pricing, -> { where(pricing_type: :free) }

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_validation :set_default_status
  before_validation :set_default_pricing_type

  # Instance methods
  def live?
    status == "live"
  end

  def draft?
    status == "draft"
  end

  def featured?
    featured_at.present?
  end

  def product_of_day?
    product_of_day_at.present?
  end

  def can_be_edited_by?(user)
    return false unless user.present?
    return true if user.admin?

    # Makers can always edit
    return true if makers.include?(user)

    # Original submitter can edit within 24 hours of launch
    return true if self.user == user && created_at > 24.hours.ago

    false
  end

  def upvotes_frozen?
    return false unless live?
    (created_at + 7.days) < Time.current
  end

  def ready_to_go_live?
    makers.present? && media.present?
  end

  def generate_slug
    base_slug = name.downcase.gsub(/[^a-z0-9\s-]/, "").strip.gsub(/\s+/, "-")
    slug = base_slug
    counter = 1

    while Product.exists?(slug: slug) && Product.find_by(slug: slug) != self
      slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug
  end

  def mark_as_featured!
    update!(featured_at: Time.current)
  end

  def mark_as_product_of_day!
    update!(product_of_day_at: Date.current)
  end

  def launch!
    return false unless ready_to_go_live?
    update!(status: :live, launch_date: Date.current)
  end

  private

  def set_default_status
    self.status ||= :draft
  end

  def set_default_pricing_type
    self.pricing_type ||= :free
  end

  def must_have_at_least_one_maker
    errors.add(:base, "Product must have at least one maker") if makers.empty?
  end

  def must_have_valid_makers
    product_makers.each do |product_maker|
      if product_maker.user_id.blank?
        errors.add(:base, "All makers must have a valid user")
      end
    end
  end

  # Business Rules
  # - Can only be edited by makers or hunters within 24hrs of launch (handled by authorization logic)
  # - Upvotes frozen after 7 days for "Product of Day" ranking (handled by a background job)
  # - Must have at least 1 maker and 1 media attachment to go live (handled by custom validation)
  # - Featured products manually selected by admins (handled by admin interface)
  # - Product of the Day selected based on upvotes in 24hr window (handled by a background job)
end
