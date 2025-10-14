# frozen_string_literal: true

class Topic < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - name (string, required, unique)
  # - slug (string, unique, indexed)
  # - description (text, nullable)
  # - icon (string, nullable) # Emoji or icon name
  # - color (string, nullable) # Hex color
  # - products_count (integer, default: 0, counter_cache)
  # - followers_count (integer, default: 0, counter_cache)
  # - position (integer, default: 0, for ordering)
  # - featured (boolean, default: false)
  # - status (integer, default: 0) # enum: 0=active, 1=inactive
  # - timestamps

  # Relationships
  has_many :product_topics, dependent: :destroy
  has_many :products, through: :product_topics
  has_many :topic_follows, dependent: :destroy
  has_many :followers, through: :topic_follows, source: :user

  # Enums
  enum :status, [ :active, :inactive ]

  # Validations
  validates :name, presence: true, uniqueness: true, length: { in: 3..50 }
  validates :slug, presence: true, uniqueness: true
  validates :description, presence: true, length: { minimum: 20, maximum: 500 }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true

  # Callbacks
  after_initialize :set_default_status, if: :new_record?
  before_validation :normalize_name, if: -> { name.present? }
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  # Scopes
  scope :featured, -> { where(featured: true).order(position: :asc) }
  scope :ordered, -> { order(position: :asc, name: :asc) }
  scope :popular, -> { order(products_count: :desc) }
  scope :by_followers, -> { order(followers_count: :desc) }

  # Business Rules
  # - Featured topics shown prominently on homepage
  # - Position determines display order for featured topics
  # - Max 20 featured topics to maintain focus

  def to_param
    slug
  end

  def set_default_status
    self.status ||= :active
  end

  def normalize_name
    self.name = name.strip.titleize
  end

  def generate_slug
    base_slug = name.downcase.gsub(/[^a-z0-9\s-]/, "").strip.gsub(/\s+/, "-")
    slug = base_slug
    counter = 1

    while Topic.exists?(slug: slug) && Topic.find_by(slug: slug) != self
      slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug
  end

  def can_be_featured?
    !featured? && Topic.where(featured: true).count < 20
  end

  def mark_as_featured!
    update!(featured: true) if can_be_featured?
  end

  def remove_from_featured!
    update!(featured: false)
  end
end
