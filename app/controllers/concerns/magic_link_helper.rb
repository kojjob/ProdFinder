# frozen_string_literal: true

module MagicLinkHelper
  extend ActiveSupport::Concern

  private

  def log_magic_link(user, token)
    return unless Rails.env.development?

    magic_link_url = magic_link_url(user, user: { email: user.email, token: token, remember_me: false })

    Rails.logger.info "🔮 MAGIC LINK GENERATED"
    Rails.logger.info "📧 Email: #{user.email}"
    Rails.logger.info "🔗 Link: #{magic_link_url}"
    Rails.logger.info "⏰ Expires: #{Devise.passwordless_login_within.from_now}"

    puts "\n" + "🔮 MAGIC LINK FOR #{user.email} 🔮".center(80, "=")
    puts "🔗 #{magic_link_url}".center(80)
    puts "⏰ Expires in #{Devise.passwordless_login_within.inspect}".center(80)
    puts "="*80 + "\n"
  end
end
