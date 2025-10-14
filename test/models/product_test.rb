# frozen_string_literal: true

require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @product = Product.new(
      name: "Test Product",
      tagline: "A great product for testing",
      description: "This is a detailed description of the test product. It should be at least 50 characters long to pass validation.",
      website_url: "https://example.com",
      slug: "test-product",
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @product.valid?
  end

  test "should require name" do
    @product.name = ""
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test "should require tagline" do
    @product.tagline = ""
    assert_not @product.valid?
    assert_includes @product.errors[:tagline], "can't be blank"
  end

  test "should require description" do
    @product.description = ""
    assert_not @product.valid?
    assert_includes @product.errors[:description], "can't be blank"
  end

  test "should require website_url" do
    @product.website_url = ""
    assert_not @product.valid?
    assert_includes @product.errors[:website_url], "can't be blank"
  end

  test "should validate name length" do
    @product.name = "ab" # too short
    assert_not @product.valid?

    @product.name = "a" * 101 # too long
    assert_not @product.valid?

    @product.name = "Valid Name"
    assert @product.valid?
  end

  test "should validate tagline length" do
    @product.tagline = "short" # too short
    assert_not @product.valid?

    @product.tagline = "a" * 101 # too long
    assert_not @product.valid?

    @product.tagline = "A valid tagline for testing"
    assert @product.valid?
  end

  test "should validate description length" do
    @product.description = "Too short"
    assert_not @product.valid?

    @product.description = "a" * 5001 # too long
    assert_not @product.valid?

    @product.description = "This is a valid description that meets the minimum length requirement for testing purposes."
    assert @product.valid?
  end

  test "should validate website_url format" do
    @product.website_url = "invalid_url"
    assert_not @product.valid?
  end

  test "should have default values" do
    product = Product.new(
      name: "Test",
      tagline: "Test tagline that is long enough",
      description: "Test description that is long enough to meet the minimum requirement",
      website_url: "https://example.com",
      user: @user
    )

    assert_equal "draft", product.status
    assert_equal "free", product.pricing_type
    assert_equal true, product.africa_focused
    assert_equal [], product.countries_available
    assert_equal 0, product.upvotes_count
    assert_equal 0, product.comments_count
    assert_equal 0, product.views_count
    assert_equal false, product.maker_inside
  end

  test "should validate unique slug" do
    @product.slug = "test-product"
    @product.save!

    duplicate_product = Product.new(
      name: "Another Product",
      tagline: "Another tagline for testing",
      description: "Another description that meets the length requirement",
      website_url: "https://another.com",
      slug: "test-product",
      user: @user
    )
    assert_not duplicate_product.valid?
  end

  test "should have associations" do
    assert_respond_to @product, :product_makers
    assert_respond_to @product, :makers
    assert_respond_to @product, :media
    assert_respond_to @product, :upvotes
    assert_respond_to @product, :comments
  end

  test "should belong to user" do
    assert_respond_to @product, :user
  end

  test "should have enum status" do
    assert_respond_to Product, :draft
    assert_respond_to Product, :scheduled
    assert_respond_to Product, :live
    assert_respond_to Product, :archived
  end

  test "should have enum pricing_type" do
    assert_respond_to Product, :free
    assert_respond_to Product, :freemium
    assert_respond_to Product, :paid
    assert_respond_to Product, :subscription
  end

  test "should generate slug automatically" do
    product = Product.new(
      name: "Awesome Product",
      tagline: "A great tagline for testing purposes",
      description: "This is a valid description that meets the minimum length requirement for testing",
      website_url: "https://example.com",
      user: @user
    )
    product.valid?
    assert_equal "awesome-product", product.slug
  end

  test "should generate unique slug for duplicate names" do
    existing_product = Product.create!(
      name: "Awesome Product",
      tagline: "A great tagline for testing purposes",
      description: "This is a valid description that meets the minimum length requirement for testing",
      website_url: "https://example.com",
      slug: "awesome-product",
      user: @user
    )

    new_product = Product.new(
      name: "Awesome Product",
      tagline: "Another great tagline for testing",
      description: "This is another valid description that meets the minimum length requirement for testing",
      website_url: "https://another.com",
      user: @user
    )
    new_product.valid?
    assert_equal "awesome-product-1", new_product.slug
  end

  test "should know if live" do
    @product.status = :live
    assert @product.live?
    assert_not @product.draft?
  end

  test "should know if draft" do
    @product.status = :draft
    assert @product.draft?
    assert_not @product.live?
  end

  test "should know if featured" do
    assert_not @product.featured?
    @product.featured_at = Time.current
    assert @product.featured?
  end

  test "should know if product of day" do
    assert_not @product.product_of_day?
    @product.product_of_day_at = Date.current
    assert @product.product_of_day?
  end

  test "should mark as featured" do
    assert_not @product.featured?
    @product.mark_as_featured!
    assert @product.featured?
  end

  test "should mark as product of day" do
    assert_not @product.product_of_day?
    @product.mark_as_product_of_day!
    assert @product.product_of_day?
  end

  # Tests for user_id association and bigint fix
  test "should handle bigint user_id correctly" do
    @product.save!

    # Verify user_id is stored as integer (bigint)
    assert_equal @user.id, @product.user_id
    assert_kind_of Integer, @product.user_id

    # Verify association works
    assert_equal @user, @product.user
  end

  test "should allow nil user_id" do
    @product.user = nil
    assert @product.valid?
    assert_nil @product.user_id
  end

  test "should have many product_makers" do
    assert_respond_to @product, :product_makers
    assert_respond_to @product, :makers
  end

  test "should create product makers through association" do
    @product.save!

    product_maker = @product.product_makers.create!(
      user: @user,
      role: :founder,
      position: 0
    )

    assert_includes @product.product_makers, product_maker
    assert_includes @product.makers, @user
  end

test "should validate at least one maker" do
    @product.save!

    # Should be invalid without makers
    assert_not @product.valid?
    assert_includes @product.errors[:base], "Product must have at least one maker"

    # Should be valid with makers
    @product.product_makers.create!(
      user: @user,
      role: :founder,
      position: 0
    )
    assert @product.valid?
  end

test "should validate maker existence" do
    @product.save!

    # Create maker with non-existent user
    product_maker = @product.product_makers.build(
      user_id: 99999, # Non-existent user ID
      role: :founder,
      position: 0
    )

    assert_not @product.valid?
    # The validation might show different error messages
    # Check that there's some validation error related to makers
    maker_errors = @product.errors.full_messages.any? { |msg| msg.include?("maker") || msg.include?("Product makers") }
    assert maker_errors, "Expected maker validation error, got: #{@product.errors.full_messages.join(', ')}"
  end

  test "should handle user association after save" do
    @product.save!

    # Test that user association works correctly after save
    assert_equal @user, @product.user
    assert_equal @user.email, @product.user.email
    assert_equal @user.username, @product.user.username
  end
end
