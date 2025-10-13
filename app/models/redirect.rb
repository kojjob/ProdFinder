# frozen_string_literal: true

class Redirect < ApplicationRecord
  validates :from_path, presence: true, uniqueness: true, format: { with: %r{\A/.*} }
  validates :to_path, presence: true, format: { with: %r{\A/.*} }
  validates :status_code, inclusion: { in: [ 301, 302, 303, 307, 308 ] }
  validates :expires_at, presence: false

  scope :active, -> { where(active: true).where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :by_status_code, ->(code) { where(status_code: code) }

  before_validation :normalize_paths
  before_validation :set_default_status_code

  def self.ransackable_attributes(auth_object = nil)
    %w[from_path to_path status_code active]
  end

  def active?
    active? && (expires_at.nil? || expires_at > Time.current)
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def permanent?
    status_code == 301
  end

  def temporary?
    [ 302, 303, 307, 308 ].include?(status_code)
  end

  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end

  def set_expiration(days_from_now)
    update!(expires_at: days_from_now.days.from_now)
  end

  def self.find_by_path(path)
    active.find_by(from_path: path)
  end

  def self.matching_redirects(path)
    # Handle wildcard redirects
    active.where("from_path = ? OR from_path LIKE ?", path, "#{path.split('/').first}%")
  end

  def self.cleanup_expired
    expired.update_all(active: false)
  end

  def redirect_stats
    {
      from_path: from_path,
      to_path: to_path,
      status_code: status_code,
      active: active?,
      expires_at: expires_at,
      permanent: permanent?
    }
  end

  private

  def normalize_paths
    self.from_path = "/#{from_path.to_s.gsub(%r{\A/+|/+\z}, '')}" if from_path.present?
    self.to_path = "/#{to_path.to_s.gsub(%r{\A/+|/+\z}, '')}" if to_path.present?
  end

  def set_default_status_code
    self.status_code ||= 301
  end
end
