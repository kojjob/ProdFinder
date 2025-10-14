# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :magic_link_authenticatable, :registerable, :confirmable,
         :rememberable, :validatable, :trackable

  # Relationships - Products
  has_many :product_makers, dependent: :destroy
  has_many :products, through: :product_makers, source: :product
  has_many :upvotes, dependent: :destroy
  has_many :upvoted_products, through: :upvotes, source: :product
  has_many :comments, dependent: :destroy
  has_many :comment_upvotes, dependent: :destroy

  # Relationships - Social
  has_many :follower_relationships, class_name: "Follow", foreign_key: "followee_id", dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower
  has_many :following_relationships, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :following_relationships, source: :followee

  # Relationships - Topics & Collections
  has_many :topic_follows, dependent: :destroy
  has_many :followed_topics, through: :topic_follows, source: :topic
  has_many :collections, dependent: :destroy

  # Relationships - Notifications
  has_many :notifications, dependent: :destroy
  has_many :triggered_notifications, class_name: "Notification", foreign_key: "actor_id", dependent: :nullify

  # Relationships - Blog
  has_many :posts, as: :author, dependent: :destroy
  has_many :blog_comments, dependent: :destroy
  has_many :approved_blog_comments, -> { approved }, class_name: "BlogComment"

  # Relationships - SEO
  has_many :seo_metadata, as: :seoable, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true,
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" },
            length: { minimum: 3, maximum: 30 }
  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :bio, length: { maximum: 500 }
  validates :website_url, format: { with: URI.regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :twitter_handle, format: { with: /\A@[a-zA-Z0-9_]+\z/, message: "must start with @ and contain only letters, numbers, and underscores" }, allow_blank: true
  # TODO: Add country code validation with ISO3166 gem
  # validates :country_code, inclusion: { in: ISO3166::Country.codes }, allow_blank: true

  # Passwordless authentication using devise-passwordless gem

  # Scopes
  scope :makers, -> { where(maker_status: true) }
  scope :verified, -> { where(verified: true) }
  scope :by_reputation, -> { order(reputation_score: :desc) }
  scope :recent, -> { order(created_at: :desc) }

  # Business Rules
  # - Reputation earned through: launches, upvotes received, quality comments
  # - Verified status manually granted by admins
  # - Can't change username more than once per 30 days
  # - Maker status automatically set when first product launched
end
