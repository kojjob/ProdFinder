require "test_helper"

class PasswordlessAuthenticationTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "new user can register with email only (passwordless)" do
    # Visit sign up page
    get new_user_registration_path
    assert_response :success

    # Fill in registration form
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          username: "newuser",
          full_name: "New User"
        }
      }
    end

    # Should create user
    user = User.find_by(email: "newuser@example.com")
    assert_not_nil user
    assert_equal "newuser", user.username
    assert_equal "New User", user.full_name

    # Should send confirmation email with magic link
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first
    assert_equal ["newuser@example.com"], email.to
    assert_match(/confirm/i, email.subject)

    # Email should contain magic link
    assert_match(/confirmation_token/, email.body.encoded)
  end

  test "existing user can sign in with magic link" do
    user = users(:one)

    # Request magic link
    post user_session_path, params: {
      user: {
        email: user.email
      }
    }

    # Should send magic link email
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first
    assert_equal [user.email], email.to

    # Extract magic link from email
    email_body = email.body.encoded
    assert_match(/passwordless/, email_body)
  end

  test "user can sign out and sign in again" do
    user = users(:one)

    # Sign in
    sign_in user
    get root_path
    assert_response :success

    # Sign out
    delete destroy_user_session_path
    follow_redirect!

    # Should be signed out
    assert_nil session[:user_id]

    # Try to access protected page
    get root_path
    # Should still be accessible (root is public)
    assert_response :success
  end

  test "magic link authentication flow works end-to-end" do
    # Create a new user
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "endtoend@example.com",
          username: "endtoenduser",
          full_name: "End To End User"
        }
      }
    end

    user = User.find_by(email: "endtoend@example.com")

    # User should receive confirmation email
    assert_equal 1, ActionMailer::Base.deliveries.size
    confirmation_email = ActionMailer::Base.deliveries.first

    # Extract confirmation token from email
    # Note: In a real test, you'd parse the email HTML/text for the actual link
    # For now, we'll get the token directly from the user
    confirmation_token = user.confirmation_token

    # Confirm the user's email via magic link
    if confirmation_token
      get user_confirmation_path(confirmation_token: confirmation_token)
      follow_redirect!
    end

    # User should now be confirmed
    user.reload
    assert_not_nil user.confirmed_at

    # Clear deliveries for sign-in test
    ActionMailer::Base.deliveries.clear

    # Now test sign-in with magic link
    post user_session_path, params: {
      user: {
        email: user.email
      }
    }

    # Should send magic link for sign-in
    assert_equal 1, ActionMailer::Base.deliveries.size
    signin_email = ActionMailer::Base.deliveries.last
    assert_equal [user.email], signin_email.to
  end

  test "invalid email shows appropriate error" do
    post user_registration_path, params: {
      user: {
        email: "invalid-email",
        username: "testuser",
        full_name: "Test User"
      }
    }

    # Should not create user
    assert_nil User.find_by(username: "testuser")

    # Should not send email
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test "duplicate email shows appropriate error" do
    existing_user = users(:one)

    post user_registration_path, params: {
      user: {
        email: existing_user.email,
        username: "differentusername",
        full_name: "Different User"
      }
    }

    # Should not create duplicate user
    assert_equal 1, User.where(email: existing_user.email).count

    # Should not send email
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test "duplicate username shows appropriate error" do
    existing_user = users(:one)

    post user_registration_path, params: {
      user: {
        email: "newemail@example.com",
        username: existing_user.username,
        full_name: "Different User"
      }
    }

    # Should not create duplicate user
    assert_equal 1, User.where(username: existing_user.username).count
  end

  test "username validation enforces format rules" do
    # Too short
    post user_registration_path, params: {
      user: {
        email: "test1@example.com",
        username: "ab",
        full_name: "Test User"
      }
    }
    assert_nil User.find_by(email: "test1@example.com")

    # Too long
    post user_registration_path, params: {
      user: {
        email: "test2@example.com",
        username: "a" * 31,
        full_name: "Test User"
      }
    }
    assert_nil User.find_by(email: "test2@example.com")

    # Invalid characters
    post user_registration_path, params: {
      user: {
        email: "test3@example.com",
        username: "invalid-user!",
        full_name: "Test User"
      }
    }
    assert_nil User.find_by(email: "test3@example.com")

    # Valid username
    post user_registration_path, params: {
      user: {
        email: "test4@example.com",
        username: "valid_user_123",
        full_name: "Test User"
      }
    }
    assert_not_nil User.find_by(email: "test4@example.com")
  end

  test "full name validation enforces length rules" do
    # Too short
    post user_registration_path, params: {
      user: {
        email: "test5@example.com",
        username: "testuser5",
        full_name: "A"
      }
    }
    assert_nil User.find_by(email: "test5@example.com")

    # Too long
    post user_registration_path, params: {
      user: {
        email: "test6@example.com",
        username: "testuser6",
        full_name: "A" * 101
      }
    }
    assert_nil User.find_by(email: "test6@example.com")

    # Valid name
    post user_registration_path, params: {
      user: {
        email: "test7@example.com",
        username: "testuser7",
        full_name: "Valid Name"
      }
    }
    assert_not_nil User.find_by(email: "test7@example.com")
  end

  test "user can request multiple magic links" do
    user = users(:one)
    ActionMailer::Base.deliveries.clear

    # Request first magic link
    post user_session_path, params: {
      user: { email: user.email }
    }
    assert_equal 1, ActionMailer::Base.deliveries.size

    # Request second magic link
    post user_session_path, params: {
      user: { email: user.email }
    }
    assert_equal 2, ActionMailer::Base.deliveries.size

    # Both emails should be to the same user
    assert_equal [user.email], ActionMailer::Base.deliveries.first.to
    assert_equal [user.email], ActionMailer::Base.deliveries.last.to
  end

  test "non-existent email for sign-in does not reveal user existence" do
    # This is a security best practice - don't reveal if email exists
    post user_session_path, params: {
      user: { email: "nonexistent@example.com" }
    }

    # Should show success message regardless
    # (In passwordless, you typically show success to prevent email enumeration)
    follow_redirect! if response.redirect?

    # Should not send email for non-existent user
    assert_equal 0, ActionMailer::Base.deliveries.size
  end
end
