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
end
