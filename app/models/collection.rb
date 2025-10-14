# frozen_string_literal: true

class Collection < ApplicationRecord
  # Attributes:
  # - id (uuid, primary key)
  # - user_id (uuid, foreign key, indexed)
  # - name (string, required)
  # - slug (string, unique, indexed)
  # - description (text, required)
  # - cover_image_url (string, nullable)
  # - featured (boolean, default: false)
  # - products_count (integer, default: 0, counter_cache)
  # - followers_count (integer, default: 0, counter_cache)
  # - upvotes_count (integer, default: 0, counter_cache)
  # - visibility (enum: public, unlisted, private)
  # - timestamps

  # Enums
  enum :visibility, { public: 0, unlisted: 1, private: 2 }, prefix: true

  # Relationships
  belongs_to :user
  has_many :collection_products, dependent: :destroy
  has_many :products, through: :collection_products

  # Validations
  validates :name, presence: true, length: { in: 3..100 }
  validates :description, presence: true, length: { in: 10..1000 }
  validates :slug, presence: true, uniqueness: true

  validate :max_products_per_collection

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  # Scopes
  scope :featured, -> { where(featured: true).order(created_at: :desc) }
  scope :public_collections, -> { where(visibility: :public) }
  scope :by_upvotes, -> { order(upvotes_count: :desc) }
  scope :recent, -> { order(created_at: :desc) }

  # Business Rules
  # - Collections help users curate and discover products
  # - Featured collections promoted on homepage
  # - Private collections only visible to owner
  # - Max 50 products per collection

  def to_param
    slug
  end

  # enum provides public?/private?/unlisted? predicates

  def visible_to?(user)
    return true if public?
    return true if user == self.user
    false
  end

  def generate_slug
    base_slug = name.downcase.gsub(/[^a-z0-9\s-]/, "").strip.gsub(/\s+/, "-")
    slug = base_slug
    counter = 1

    while Collection.exists?(slug: slug) && Collection.find_by(slug: slug) != self
      slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug
  end

  def can_be_featured?
    public? && !featured?
  end

  def mark_as_featured!
    update!(featured: true) if can_be_featured?
  end

  private

  def max_products_per_collection
    if collection_products.count >= 50
      errors.add(:base, "Maximum 50 products allowed per collection")
    end
  end
end
