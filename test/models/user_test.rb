# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      username: "testuser",
      full_name: "Test User",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = ""
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require username" do
    @user.username = ""
    assert_not @user.valid?
    assert_includes @user.errors[:username], "can't be blank"
  end

  test "should require full_name" do
    @user.full_name = ""
    assert_not @user.valid?
    assert_includes @user.errors[:full_name], "can't be blank"
  end

  test "should validate email format" do
    @user.email = "invalid_email"
    assert_not @user.valid?
  end

  test "should validate username format" do
    @user.username = "invalid username!"
    assert_not @user.valid?
  end

  test "should validate username length" do
    @user.username = "ab" # too short
    assert_not @user.valid?

    @user.username = "a" * 31 # too long
    assert_not @user.valid?

    @user.username = "valid_user"
    assert @user.valid?
  end

  test "should validate full_name length" do
    @user.full_name = "a" # too short
    assert_not @user.valid?

    @user.full_name = "a" * 101 # too long
    assert_not @user.valid?
  end

  test "should validate bio length" do
    @user.bio = "a" * 501 # too long
    assert_not @user.valid?
  end

  test "should have default values" do
    user = User.new(
      email: "test2@example.com",
      username: "testuser2",
      full_name: "Test User 2",
      password: "password123"
    )

    assert_equal 0, user.reputation_score
    assert_equal false, user.maker_status
    assert_equal false, user.admin
    assert_equal false, user.verified
    assert_equal true, user.email_notifications
    assert_equal "Africa/Accra", user.timezone
  end

  test "should validate unique email" do
    # TODO: Fix Devise test setup for uniqueness validation
    skip "Devise test configuration needed"
  end

  test "should validate unique username" do
    # TODO: Fix Devise test setup for uniqueness validation
    skip "Devise test configuration needed"
  end

  test "should have associations" do
    assert_respond_to @user, :product_makers
    assert_respond_to @user, :products
    assert_respond_to @user, :upvotes
    assert_respond_to @user, :comments
  end
end
