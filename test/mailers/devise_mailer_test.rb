require "test_helper"

class DeviseMailerTest < ActionMailer::TestCase
  def setup
    @user = users(:one)
    @token = "sample_token_123"
  end

  test "magic link email is sent with correct recipient" do
    email = DeviseMailer.magic_link(@user, @token, {})

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
    assert_equal [ "noreply@prodfinder.com" ], email.from
    assert_match(/magic link/i, email.subject)
  end

  test "magic link email contains the magic link URL" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check that email body contains token
    assert_match @token, email.body.encoded

    # Check that email contains magic link text
    assert_match(/Sign in to ProdFinder/i, email.body.encoded)
    assert_match(/magic link/i, email.body.encoded)
  end

  test "magic link email contains security information" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check for expiration notice
    assert_match(/expires/i, email.body.encoded)

    # Check for security notice
    assert_match(/password/i, email.body.encoded)
    assert_match(/security/i, email.body.encoded)
  end

  test "magic link email contains company branding" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check for company name
    assert_match(/ProdFinder/i, email.body.encoded)

    # Check for root URL
    assert_match(/#{ENV.fetch('HOST', 'localhost:3000')}/i, email.body.encoded) rescue
    assert_match(/localhost/i, email.body.encoded)
  end

  test "magic link email has proper HTML structure" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check for HTML email
    assert email.html_part.present?, "Email should have HTML part"

    # Check for responsive email structure
    assert_match(/viewport/i, email.html_part.body.encoded)
    assert_match(/max-width/i, email.html_part.body.encoded)
  end

  test "magic link email contains help text for non-requesters" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check for help text
    assert_match(/didn't request/i, email.body.encoded)
    assert_match(/ignore this email/i, email.body.encoded)
  end

  test "magic link email has accessible button" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check for button/link with descriptive text
    assert_match(/href=/i, email.body.encoded)
    assert_match(/Sign in/i, email.body.encoded)
  end

  test "passwordless login email is sent correctly" do
    email = DeviseMailer.passwordless_login(@user, @token, {})

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
  end

  test "passwordless login email contains login link" do
    email = DeviseMailer.passwordless_login(@user, @token, {})

    # Check that email contains login information
    assert_match(/log in/i, email.body.encoded)
    assert_match(@token, email.body.encoded)
  end

  test "passwordless login email contains expiration info" do
    email = DeviseMailer.passwordless_login(@user, @token, {})

    # Check for expiration notice
    assert_match(/expire/i, email.body.encoded)
    assert_match(/Devise.passwordless_login_within/i, email.body.encoded)
  end

  test "confirmation instructions email is sent correctly" do
    @user.confirmation_token = "confirmation_token_123"
    @user.confirmation_sent_at = Time.current

    email = Devise::Mailer.confirmation_instructions(@user, @user.confirmation_token, {})

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
    assert_match(/confirm/i, email.subject)
  end

  test "confirmation instructions email contains confirmation link" do
    @user.confirmation_token = "confirmation_token_123"
    @user.confirmation_sent_at = Time.current

    email = Devise::Mailer.confirmation_instructions(@user, @user.confirmation_token, {})

    # Check that email contains confirmation token
    assert_match(@user.confirmation_token, email.body.encoded)

    # Check that email contains confirmation instructions
    assert_match(/confirm/i, email.body.encoded)
  end

  test "email changed notification is sent correctly" do
    email = Devise::Mailer.email_changed(@user, {})

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
    assert_match(/email.*changed/i, email.subject)
  end

  test "unlock instructions email is sent correctly" do
    @user.locked_at = Time.current
    @user.unlock_token = "unlock_token_123"

    email = Devise::Mailer.unlock_instructions(@user, @user.unlock_token, {})

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ @user.email ], email.to
    assert_match(/unlock/i, email.subject)
  end

  test "unlock instructions email contains unlock link" do
    @user.locked_at = Time.current
    @user.unlock_token = "unlock_token_123"

    email = Devise::Mailer.unlock_instructions(@user, @user.unlock_token, {})

    # Check that email contains unlock token
    assert_match(@user.unlock_token, email.body.encoded)

    # Check that email contains unlock instructions
    assert_match(/unlock/i, email.body.encoded)
  end

  test "emails have consistent branding" do
    emails = [
      Devise::Mailer.magic_link(@user, @token, {}),
      Devise::Mailer.passwordless_login(@user, @token, {})
    ]

    emails.each do |email|
      # All emails should have consistent from address
      assert_equal [ "noreply@prodfinder.com" ], email.from

      # All emails should mention the app name
      assert_match(/ProdFinder/i, email.body.encoded)
    end
  end

  test "emails contain required legal links" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check for privacy and terms links
    assert_match(/Privacy Policy/i, email.body.encoded)
    assert_match(/Terms of Service/i, email.body.encoded)
  end

  test "emails are mobile-responsive" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check for responsive meta tags
    assert_match(/viewport/i, email.html_part.body.encoded)
    assert_match(/device-width/i, email.html_part.body.encoded)

    # Check for responsive table structure
    assert_match(/max-width.*600/i, email.html_part.body.encoded)
  end

  test "emails have fallback text for email clients" do
    email = DeviseMailer.magic_link(@user, @token, {})

    # Check for alternative text
    assert_match(/Or copy and paste/i, email.body.encoded)
  end
end
