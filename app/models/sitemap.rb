# frozen_string_literal: true

class Sitemap < ApplicationRecord
  validates :url, presence: true, uniqueness: true
  validates :priority, inclusion: { in: 0.0..1.0 }, allow_nil: true
  validates :changefreq, inclusion: { in: %w[always hourly daily weekly monthly yearly never] }, allow_blank: true
  validates :sitemap_type, presence: true

  enum :sitemap_type, { page: 0, post: 1, product: 2, category: 3, user: 4, custom: 5 }

  scope :by_type, ->(type) { where(sitemap_type: type) }
  scope :high_priority, -> { where("priority >= ?", 0.8) }
  scope :recently_updated, -> { where("lastmod >= ?", 1.week.ago) }

  before_validation :set_defaults
  before_save :normalize_url

  def self.ransackable_attributes(auth_object = nil)
    %w[url priority changefreq sitemap_type]
  end

  def high_priority?
    priority.present? && priority >= 0.8
  end

  def recently_updated?
    lastmod.present? && lastmod >= 1.week.ago
  end

  def update_lastmod!
    update!(lastmod: Time.current)
  end

  def self.generate_for_posts
    Post.published.find_each do |post|
      url = "https://#{ENV['DOMAIN'] || 'localhost:3000'}/blog/posts/#{post.slug}"
      find_or_create_by!(url: url) do |sitemap|
        sitemap.sitemap_type = :post
        sitemap.priority = post.featured? ? 0.9 : 0.7
        sitemap.changefreq = "weekly"
        sitemap.lastmod = post.updated_at
      end
    end
  end

  def self.generate_for_products
    Product.live.find_each do |product|
      url = "https://#{ENV['DOMAIN'] || 'localhost:3000'}/products/#{product.slug}"
      find_or_create_by!(url: url) do |sitemap|
        sitemap.sitemap_type = :product
        sitemap.priority = product.featured? ? 0.9 : 0.6
        sitemap.changefreq = "daily"
        sitemap.lastmod = product.updated_at
      end
    end
  end

  def self.generate_for_categories
    Category.with_posts.find_each do |category|
      url = "https://#{ENV['DOMAIN'] || 'localhost:3000'}/blog/categories/#{category.slug}"
      find_or_create_by!(url: url) do |sitemap|
        sitemap.sitemap_type = :category
        sitemap.priority = 0.5
        sitemap.changefreq = "weekly"
        sitemap.lastmod = category.updated_at
      end
    end
  end

  def self.generate_static_pages
    static_pages = [
      { path: "/", priority: 1.0, changefreq: "daily" },
      { path: "/products", priority: 0.9, changefreq: "daily" },
      { path: "/blog", priority: 0.8, changefreq: "daily" },
      { path: "/about", priority: 0.5, changefreq: "monthly" },
      { path: "/contact", priority: 0.4, changefreq: "yearly" }
    ]

    static_pages.each do |page|
      url = "https://#{ENV['DOMAIN'] || 'localhost:3000'}#{page[:path]}"
      find_or_create_by!(url: url) do |sitemap|
        sitemap.sitemap_type = :page
        sitemap.priority = page[:priority]
        sitemap.changefreq = page[:changefreq]
        sitemap.lastmod = Time.current
      end
    end
  end

  def self.generate_all
    generate_static_pages
    generate_for_posts
    generate_for_products
    generate_for_categories
  end

  def self.cleanup_stale
    where("lastmod < ?", 1.month.ago).delete_all
  end

  private

  def set_defaults
    self.priority ||= 0.5
    self.changefreq ||= "weekly"
    self.lastmod ||= Time.current
  end

  def normalize_url
    self.url = url.strip if url.present?
  end
end
