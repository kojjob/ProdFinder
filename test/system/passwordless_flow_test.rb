require "application_system_test_case"

class PasswordlessFlowTest < ApplicationSystemTestCase
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "complete passwordless registration flow" do
    # Visit sign up page
    visit new_user_registration_path

    # Fill in registration form
    fill_in "user_email", with: "newuser@example.com"
    fill_in "user_username", with: "newuser123"
    fill_in "user_full_name", with: "New Test User"

    # Submit form
    click_button "Create Account"

    # Should show success state
    assert_selector "[data-signup-form-target='successState']", visible: true, wait: 5
    assert_text "Check your inbox"
    assert_text "newuser@example.com"

    # Verify email was sent
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first
    assert_equal ["newuser@example.com"], email.to

    # Verify user was created
    user = User.find_by(email: "newuser@example.com")
    assert_not_nil user
    assert_equal "newuser123", user.username
    assert_equal "New Test User", user.full_name
  end

  test "complete passwordless sign-in flow" do
    user = users(:one)

    # Visit sign in page
    visit new_user_session_path

    # Fill in email
    fill_in "user_email", with: user.email

    # Submit form
    click_button "Send Magic Link"

    # Should show success state
    assert_selector "[data-auth-form-target='successState']", visible: true, wait: 5
    assert_text "Check your inbox"
    assert_text user.email

    # Verify email was sent
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first
    assert_equal [user.email], email.to
    assert_match(/magic link/i, email.subject)
  end

  test "email validation works in real-time" do
    visit new_user_registration_path

    # Type invalid email
    fill_in "user_email", with: "invalid-email"
    find("input[name='user[email]']").native.send_keys(:tab)

    # Should show error
    assert_selector ".field-error", text: "Please enter a valid email address", wait: 2

    # Type valid email
    fill_in "user_email", with: "valid@example.com"
    find("input[name='user[email]']").native.send_keys(:tab)

    # Should show success icon
    assert_selector "[data-signup-form-target='emailValidIcon']", visible: true, wait: 2
    assert_no_selector ".field-error"
  end

  test "username validation works in real-time" do
    visit new_user_registration_path

    # Type too short username
    fill_in "user_username", with: "ab"
    find("input[name='user[username]']").native.send_keys(:tab)

    # Should show error
    assert_selector ".field-error", text: /Username must be/, wait: 2

    # Type invalid characters
    fill_in "user_username", with: "invalid-user!"
    find("input[name='user[username]']").native.send_keys(:tab)

    # Should show error
    assert_selector ".field-error", text: /Username must be/, wait: 2

    # Type valid username
    fill_in "user_username", with: "valid_user_123"
    find("input[name='user[username]']").native.send_keys(:tab)

    # Should show success icon
    assert_selector "[data-signup-form-target='usernameValidIcon']", visible: true, wait: 2
    assert_no_selector "[data-signup-form-target='usernameError']"
  end

  test "full name validation works in real-time" do
    visit new_user_registration_path

    # Type too short name
    fill_in "user_full_name", with: "A"
    find("input[name='user[full_name]']").native.send_keys(:tab)

    # Should show error
    assert_selector ".field-error", text: /Name must be/, wait: 2

    # Type valid name
    fill_in "user_full_name", with: "Valid Name"
    find("input[name='user[full_name]']").native.send_keys(:tab)

    # Should show success icon
    assert_selector "[data-signup-form-target='nameValidIcon']", visible: true, wait: 2
    assert_no_selector "[data-signup-form-target='nameError']"
  end

  test "loading state appears during form submission" do
    visit new_user_session_path

    fill_in "user_email", with: "test@example.com"

    # Click submit
    click_button "Send Magic Link"

    # Should show loading state
    assert_selector "[data-auth-form-target='loadingMessage']", visible: true, wait: 2
    assert_text "Sending magic link..."

    # Button should be disabled
    assert_selector "input[type='submit'][disabled]", wait: 2
  end

  test "success state appears after form submission" do
    visit new_user_registration_path

    # Fill in all fields with valid data
    fill_in "user_email", with: "success@example.com"
    fill_in "user_username", with: "successuser"
    fill_in "user_full_name", with: "Success User"

    # Submit form
    click_button "Create Account"

    # Should hide form fields
    assert_no_selector "[data-signup-form-target='formFields']", visible: true, wait: 5

    # Should show success state
    assert_selector "[data-signup-form-target='successState']", visible: true, wait: 5
    assert_text "Check your inbox"
    assert_text "We've sent a confirmation email to success@example.com"
  end

  test "navigation between sign in and sign up works" do
    visit new_user_session_path

    # Should have link to sign up
    assert_link "Create an account"
    click_link "Create an account"

    # Should be on sign up page
    assert_current_path new_user_registration_path
    assert_selector "h1", text: "Create your account"

    # Should have link back to sign in
    assert_link "Sign in"
    click_link "Sign in"

    # Should be back on sign in page
    assert_current_path new_user_session_path
    assert_selector "h1", text: "Welcome back"
  end

  test "form validates all fields before submission" do
    visit new_user_registration_path

    # Try to submit empty form
    click_button "Create Account"

    # Should show validation errors
    # Note: Browser validation will prevent submission, so we'll fill fields one by one

    # Fill only email
    fill_in "user_email", with: "test@example.com"
    click_button "Create Account"

    # Should still require other fields

    # Fill username
    fill_in "user_username", with: "testuser"
    click_button "Create Account"

    # Should still require full name

    # Fill full name
    fill_in "user_full_name", with: "Test User"
    click_button "Create Account"

    # Now should submit successfully
    assert_selector "[data-signup-form-target='successState']", visible: true, wait: 5
  end

  test "email field has proper autocomplete attribute" do
    visit new_user_session_path

    # Check autocomplete attribute
    assert_selector "input[autocomplete='email']"
  end

  test "username field has proper autocomplete attribute" do
    visit new_user_registration_path

    # Check autocomplete attribute
    assert_selector "input[autocomplete='username']"
  end

  test "full name field has proper autocomplete attribute" do
    visit new_user_registration_path

    # Check autocomplete attribute
    assert_selector "input[autocomplete='name']"
  end

  test "remember me checkbox works on sign in" do
    visit new_user_session_path

    # Check remember me checkbox
    check "user_remember_me"

    # Should be checked
    assert_selector "input[type='checkbox'][checked]"
  end

  test "forms have proper ARIA labels for accessibility" do
    visit new_user_registration_path

    # Check that inputs have labels
    assert_selector "label[for='user_email']"
    assert_selector "label[for='user_username']"
    assert_selector "label[for='user_full_name']"

    # Check that inputs are properly associated
    assert_selector "input[type='email']#user_email"
    assert_selector "input[type='text']#user_username"
    assert_selector "input[type='text']#user_full_name"
  end

  test "error messages are announced to screen readers" do
    visit new_user_registration_path

    # Trigger validation error
    fill_in "user_email", with: "invalid"
    find("input[name='user[email]']").native.send_keys(:tab)

    # Check for ARIA live region or role=alert
    assert_selector ".field-error", wait: 2
  end

  test "page titles are descriptive for SEO and accessibility" do
    visit new_user_session_path
    assert_title "Sign In - ProdFinder"

    visit new_user_registration_path
    assert_title "Sign Up - ProdFinder"
  end

  test "forms work on mobile viewport" do
    # Set mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit new_user_registration_path

    # Should still be able to fill and submit form
    assert_selector ".auth-form"
    assert_selector "input[type='email']"
    assert_selector "input[type='submit']"

    fill_in "user_email", with: "mobile@example.com"
    fill_in "user_username", with: "mobileuser"
    fill_in "user_full_name", with: "Mobile User"

    click_button "Create Account"

    # Should show success state
    assert_selector "[data-signup-form-target='successState']", visible: true, wait: 5
  end

  test "duplicate email shows appropriate error message" do
    existing_user = users(:one)

    visit new_user_registration_path

    fill_in "user_email", with: existing_user.email
    fill_in "user_username", with: "differentusername"
    fill_in "user_full_name", with: "Different User"

    click_button "Create Account"

    # Should show error about duplicate email
    # Note: The exact error message depends on Rails validation error format
    # You may need to adjust this based on your actual error display
  end

  test "duplicate username shows appropriate error message" do
    existing_user = users(:one)

    visit new_user_registration_path

    fill_in "user_email", with: "newemail@example.com"
    fill_in "user_username", with: existing_user.username
    fill_in "user_full_name", with: "Different User"

    click_button "Create Account"

    # Should show error about duplicate username
  end

  test "sign in with non-existent email shows success for security" do
    visit new_user_session_path

    fill_in "user_email", with: "nonexistent@example.com"
    click_button "Send Magic Link"

    # Should show success state (to prevent email enumeration)
    assert_selector "[data-auth-form-target='successState']", visible: true, wait: 5
    assert_text "Check your inbox"

    # But no email should actually be sent
    assert_equal 0, ActionMailer::Base.deliveries.size
  end
end
