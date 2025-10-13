# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  has_many :post_categories, dependent: :destroy
  has_many :posts, through: :post_categories
  has_many :seo_metadata, as: :seoable, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }, uniqueness: true
  validates :slug, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_save :update_posts_count

  scope :root_categories, -> { where(parent_id: nil) }
  scope :featured, -> { where(featured: true) }
  scope :by_position, -> { order(position: :asc, name: :asc) }
  scope :with_posts, -> { joins(:posts).merge(Post.published).distinct }

  def to_param
    slug
  end

  def generate_slug
    base_slug = name.to_s.parameterize
    slug = base_slug.dup
    counter = 1

    while Category.exists?(slug: slug)
      slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug
  end

  def update_posts_count
    self.posts_count = posts.published.count
  end

  def root?
    parent_id.nil?
  end

  def child?
    parent_id.present?
  end

  def ancestors
    return [] if root?

    parent_ancestors = parent.ancestors
    parent_ancestors << parent
  end

  def descendants
    children.flat_map { |child| [ child ] + child.descendants }
  end

  def self_and_descendants
    [ self ] + descendants
  end

  def posts_including_descendants
    Post.published.joins(:categories).where(categories: { id: self_and_descendants })
  end

  def sibling_categories
    return Category.none if root?

    parent.children.where.not(id: id)
  end

  def move_up
    # Guard against nil positions
    return if position.nil?

    # Get minimum sibling position to check if we're at the top
    min_sibling_position = if root?
      Category.root_categories.where.not(position: nil).minimum(:position)
    else
      return unless parent.present?
      parent.children.where.not(position: nil).minimum(:position)
    end

    # Return early if we're already at the top position
    return if min_sibling_position.nil? || position <= min_sibling_position

    # Find the sibling above us
    siblings = if root?
      Category.root_categories.where.not(position: nil).where("position < ?", position).order(position: :desc).first
    else
      parent.children.where.not(position: nil).where("position < ?", position).order(position: :desc).first
    end

    return unless siblings && siblings.position.present?

    # Perform the swap only when both positions are non-nil
    old_position = position
    update!(position: siblings.position)
    siblings.update!(position: old_position)
  end

  def move_down
    # Guard against nil positions
    return if position.nil?

    # Get maximum sibling position
    max_sibling_position = if root?
      Category.root_categories.where.not(position: nil).maximum(:position)
    else
      return unless parent.present?
      parent.children.where.not(position: nil).maximum(:position)
    end

    # Return early if we're already at the bottom or no positions exist
    return if max_sibling_position.nil? || position >= max_sibling_position

    # Find the sibling below us
    siblings = if root?
      Category.root_categories.where.not(position: nil).where("position > ?", position).order(position: :asc).first
    else
      parent.children.where.not(position: nil).where("position > ?", position).order(position: :asc).first
    end

    return unless siblings && siblings.position.present?

    # Perform the swap only when both positions are non-nil
    old_position = position
    update!(position: siblings.position)
    siblings.update!(position: old_position)
  end

  def self.reorder_positions
    root_categories.each_with_index do |category, index|
      category.update!(position: index + 1)
      category.children.each_with_index do |child, child_index|
        child.update!(position: child_index + 1)
      end
    end
  end

  def popular_posts(limit = 10)
    posts.published.order(views_count: :desc).limit(limit)
  end

  def recent_posts(limit = 10)
    posts.published.order(published_at: :desc).limit(limit)
  end

  def featured_posts(limit = 5)
    posts.published.featured.limit(limit)
  end
end
