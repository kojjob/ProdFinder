# frozen_string_literal: true

require "test_helper"

class ProductCreationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "should create product with valid attributes" do
    sign_in @user

    get new_product_path
    assert_response :success

    assert_difference [ "Product.count", "ProductMaker.count" ] do
      post products_path, params: {
        product: {
          name: "Awesome Product",
          tagline: "An amazing product for everyone",
          description: "This is a detailed description of the awesome product. It has enough characters to pass validation.",
          website_url: "https://awesomeproduct.com"
        }
      }
    end

    assert_redirected_to product_path(Product.last)
    follow_redirect!
    assert_response :success

    product = Product.last
    assert_equal "Awesome Product", product.name
    assert_equal @user, product.user
    assert product.live?
    assert_equal Date.current, product.launch_date

    # Verify product maker was created
    assert_equal 1, product.product_makers.count
    product_maker = product.product_makers.first
    assert_equal @user, product_maker.user
    assert_equal "founder", product_maker.role
  end

  test "should create draft product" do
    sign_in @user

    assert_difference "Product.count" do
      post products_path, params: {
        product: {
          name: "Draft Product",
          tagline: "A draft product",
          description: "This is a draft product description with enough characters.",
          website_url: "https://draft.com"
        },
        draft: "true"
      }
    end

    product = Product.last
    assert product.draft?
    assert_nil product.launch_date
  end

  test "should not create product without authentication" do
    assert_no_difference "Product.count" do
      post products_path, params: {
        product: {
          name: "Unauthorized Product",
          tagline: "Should not be created",
          description: "This product should not be created without authentication.",
          website_url: "https://unauthorized.com"
        }
      }
    end

    assert_redirected_to new_user_session_path
    assert_not_nil flash[:alert]
  end

  test "should show validation errors for invalid product" do
    sign_in @user

    assert_no_difference "Product.count" do
      post products_path, params: {
        product: {
          name: "",
          tagline: "",
          description: "",
          website_url: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error", count: 4
  end

  test "should handle product creation with maker association" do
    sign_in @user

    post products_path, params: {
      product: {
        name: "Product with Makers",
        tagline: "Testing maker associations",
        description: "This product tests the maker association functionality.",
        website_url: "https://makers.com"
      }
    }

    product = Product.last
    assert_equal 1, product.makers.count
    assert_includes product.makers, @user
    assert_equal 1, @user.products.count
    assert_includes @user.products, product
  end

  test "should handle database type compatibility" do
    sign_in @user

    post products_path, params: {
      product: {
        name: "Type Compatibility Test",
        tagline: "Testing bigint/uuid compatibility",
        description: "This product tests the database type compatibility fix.",
        website_url: "https://compatibility.com"
      }
    }

    product = Product.last

    # Verify user_id is stored as bigint (integer)
    assert_equal @user.id, product.user_id
    assert_kind_of Integer, product.user_id

    # Verify product_id in product_makers is UUID
    product_maker = product.product_makers.first
    assert_equal product.id, product_maker.product_id
    assert_kind_of String, product_maker.product_id

    # Verify user_id in product_makers is bigint
    assert_equal @user.id, product_maker.user_id
    assert_kind_of Integer, product_maker.user_id
  end

  test "should handle multiple makers for same product" do
    sign_in @user

    other_user = users(:two)

    post products_path, params: {
      product: {
        name: "Multi-Maker Product",
        tagline: "Product with multiple makers",
        description: "This product has multiple makers for testing purposes.",
        website_url: "https://multimaker.com"
      }
    }

    product = Product.last

    # Add second maker
    product.product_makers.create!(
      user: other_user,
      role: :co_founder,
      position: 1
    )

    assert_equal 2, product.makers.count
    assert_includes product.makers, @user
    assert_includes product.makers, other_user
  end

  test "should prevent duplicate makers for same product" do
    sign_in @user

    post products_path, params: {
      product: {
        name: "Duplicate Test Product",
        tagline: "Testing duplicate prevention",
        description: "This product tests duplicate maker prevention.",
        website_url: "https://duplicate.com"
      }
    }

    product = Product.last

    # Try to create duplicate maker
    duplicate_maker = ProductMaker.new(
      product: product,
      user: @user,
      role: :co_founder
    )

    assert_not duplicate_maker.valid?
    assert_includes duplicate_maker.errors[:product_id], "has already been taken"
  end
end
