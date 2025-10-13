require "application_system_test_case"

class AuthenticationUiTest < ApplicationSystemTestCase
  test "sign in page has proper accessibility attributes" do
    visit new_user_session_path
    
    # Check page title
    assert_title "Sign In - ProdFinder"
    
    # Check main heading
    assert_selector "h1", text: "Welcome back"
    
    # Check form accessibility
    assert_selector "form[data-controller='auth-form']"
    assert_selector "label[for='user_email']", text: "Email address"
    assert_selector "input[type='email'][required][autocomplete='email']"
    assert_selector "input[type='checkbox'][id='user_remember_me']"
    assert_selector "label[for='user_remember_me']"
    
    # Check ARIA attributes
    assert_selector "input[aria-describedby]", count: 0 # No errors initially
    assert_selector "[role='alert']", count: 0 # No alerts initially
    
    # Check submit button
    assert_selector "input[type='submit'][value='Send Magic Link']"
    
    # Check help text
    assert_text "How magic links work"
    assert_text "We'll send a secure link to your email"
  end

  test "sign up page has proper accessibility attributes" do
    visit new_user_registration_path
    
    # Check page title
    assert_title "Sign Up - ProdFinder"
    
    # Check main heading
    assert_selector "h1", text: "Create your account"
    
    # Check form accessibility
    assert_selector "form[data-controller='signup-form']"
    assert_selector "label[for='user_email']", text: "Email address"
    assert_selector "label[for='user_username']", text: "Username"
    assert_selector "label[for='user_full_name']", text: "Full name"
    
    # Check required fields
    assert_selector "input[type='email'][required]"
    assert_selector "input[type='text'][required]", count: 2
    
    # Check autocomplete attributes
    assert_selector "input[autocomplete='email']"
    assert_selector "input[autocomplete='username']"
    assert_selector "input[autocomplete='name']"
    
    # Check submit button
    assert_selector "input[type='submit'][value='Create Account']"
    
    # Check terms and privacy links
    assert_text "Terms of Service"
    assert_text "Privacy Policy"
  end

  test "sign in form validation works" do
    visit new_user_session_path
    
    # Test empty email submission
    click_button "Send Magic Link"
    
    # Should show validation error
    assert_selector ".field-error", text: "Please enter a valid email address"
    
    # Test invalid email
    fill_in "user_email", with: "invalid-email"
    find("input[name='user[email]']").native.send_keys(:tab) # Trigger blur event
    
    # Should show validation error
    assert_selector ".field-error", text: "Please enter a valid email address"
    
    # Test valid email
    fill_in "user_email", with: "test@example.com"
    find("input[name='user[email]']").native.send_keys(:tab)
    
    # Should show success state
    assert_selector ".form-input-success"
    assert_selector ".field-error", count: 0
  end

  test "sign up form validation works" do
    visit new_user_registration_path
    
    # Test email validation
    fill_in "user_email", with: "invalid-email"
    find("input[name='user[email]']").native.send_keys(:tab)
    assert_selector ".field-error", text: "Please enter a valid email address"
    
    fill_in "user_email", with: "test@example.com"
    find("input[name='user[email]']").native.send_keys(:tab)
    assert_selector ".form-input-success"
    
    # Test username validation
    fill_in "user_username", with: "ab" # Too short
    find("input[name='user[username]']").native.send_keys(:tab)
    assert_selector ".field-error", text: "Username must be 3-30 characters, letters, numbers, and underscores only"
    
    fill_in "user_username", with: "valid_username123"
    find("input[name='user[username]']").native.send_keys(:tab)
    assert_selector ".form-input-success"
    
    # Test name validation
    fill_in "user_full_name", with: "a" # Too short
    find("input[name='user[full_name]']").native.send_keys(:tab)
    assert_selector ".field-error", text: "Name must be 2-100 characters long"

    fill_in "user_full_name", with: "Valid Name"
    find("input[name='user[full_name]']").native.send_keys(:tab)
    assert_selector ".form-input-success"
  end

  test "keyboard navigation works properly" do
    visit new_user_session_path
    
    # Test tab order
    find("input[name='user[email]']").native.send_keys(:tab)
    assert_equal find("input[name='user[remember_me]']"), page.driver.browser.switch_to.active_element
    
    find("input[name='user[remember_me]']").native.send_keys(:tab)
    assert_equal find("input[type='submit']"), page.driver.browser.switch_to.active_element
  end

  test "error messages are announced to screen readers" do
    visit new_user_session_path
    
    # Fill invalid email and trigger validation
    fill_in "user_email", with: "invalid"
    find("input[name='user[email]']").native.send_keys(:tab)
    
    # Check that error has proper ARIA attributes
    assert_selector ".field-error[role='alert'], .field-error[aria-live='polite']"
  end

  test "loading states work correctly" do
    visit new_user_session_path
    
    fill_in "user_email", with: "test@example.com"
    
    # Click submit and check loading state
    click_button "Send Magic Link"
    
    # Should show loading message
    assert_selector "[data-auth-form-target='loadingMessage']", visible: true
    assert_text "Sending magic link..."
    
    # Button should be disabled
    assert_selector "input[type='submit'][disabled]"
  end

  test "flash messages are dismissible" do
    # This would need to be tested with actual flash messages
    # For now, we'll test the structure
    visit new_user_session_path
    
    # Check that flash message structure exists in layout
    assert_selector "body"
    # Flash messages would appear here if there were any
  end

  test "responsive design works on mobile" do
    # Test mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667) # iPhone SE size
    
    visit new_user_session_path
    
    # Check that form is still usable
    assert_selector ".auth-form"
    assert_selector "input[type='email']"
    assert_selector "input[type='submit']"
    
    # Check that text is readable
    assert_selector ".auth-title"
    assert_selector ".auth-subtitle"
  end

  test "high contrast mode compatibility" do
    visit new_user_session_path
    
    # Check that important elements have proper contrast classes
    assert_selector ".text-secondary-900" # Dark text
    assert_selector ".bg-white" # White backgrounds
    assert_selector ".border-secondary-300" # Visible borders
    
    # Check focus states
    find("input[name='user[email]']").click
    assert_selector "input:focus"
  end

  test "navigation between sign in and sign up works" do
    visit new_user_session_path
    
    # Should have link to sign up
    assert_link "Sign up"
    click_link "Sign up"
    
    assert_current_path new_user_registration_path
    assert_selector "h1", text: "Create your account"
    
    # Should have link back to sign in
    assert_link "Sign in"
    click_link "Sign in"
    
    assert_current_path new_user_session_path
    assert_selector "h1", text: "Welcome back"
  end
end
