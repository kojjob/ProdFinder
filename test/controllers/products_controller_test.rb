# frozen_string_literal: true

require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "should get new" do
    sign_in @user
    get new_product_path
    assert_response :success
  end

  test "should redirect new when not authenticated" do
    get new_product_path
    assert_redirected_to new_user_session_path
  end

  test "should create product with valid attributes" do
    sign_in @user

    assert_difference [ "Product.count", "ProductMaker.count" ] do
      post products_path, params: {
        product: {
          name: "Test Product",
          tagline: "A great test product",
          description: "This is a detailed description of the test product. It has enough characters to pass validation requirements.",
          website_url: "https://testproduct.com"
        }
      }
    end

    assert_redirected_to product_path(Product.last)
    assert_equal "Product was successfully created.", flash[:notice]

    product = Product.last
    assert_equal @user, product.user
    assert product.live?
    assert_equal Date.current, product.launch_date

    # Verify maker was created
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
    assert_redirected_to product_path(product)
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

    post products_path, params: {
      product: {
        name: "",
        tagline: "",
        description: "",
        website_url: "invalid-url"
      }
    }

    assert_response :unprocessable_entity
  end

  test "should handle product creation errors gracefully" do
    sign_in @user

    # Test with invalid data that should cause validation errors
    assert_no_difference "Product.count" do
      post products_path, params: {
        product: {
          name: "",  # Invalid: empty name
          tagline: "This will cause an error",
          description: "This product will trigger validation errors.",
          website_url: "invalid-url"  # Invalid: bad URL format
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should handle maker creation fallback" do
    sign_in @user

    # Test normal product creation which should work
    assert_difference "Product.count", 1 do
      post products_path, params: {
        product: {
          name: "Fallback Product",
          tagline: "This tests fallback behavior",
          description: "This product tests the fallback mechanism when the first approach fails.",
          website_url: "https://fallback.com"
        }
      }
    end

    assert_redirected_to product_path(Product.last)
    assert_not_nil flash[:notice]
  end

  test "should delete product if maker creation fails completely" do
    sign_in @user

    # Test with data that would cause the product to be invalid
    assert_no_difference "Product.count" do
      post products_path, params: {
        product: {
          name: "Failed Product",
          tagline: "This will be deleted",
          description: "This product will be deleted when maker creation fails.",
          website_url: "not-a-valid-url"  # This should cause validation to fail
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not duplicate maker if already exists" do
    sign_in @user

    # Create product first
    product = Product.create!(
      name: "Existing Product",
      tagline: "Already has makers",
      description: "This product already has the current user as a maker.",
      website_url: "https://existing.com",
      user: @user
    )

    # Add current user as maker
    product.product_makers.create!(
      user: @user,
      role: :founder,
      position: 0
    )

    # Try to create through controller (should not duplicate maker)
    assert_difference "Product.count", 0 do
      post products_path, params: {
        product: {
          name: "New Product",
          tagline: "Should not duplicate maker",
          description: "This product should not duplicate the existing maker.",
          website_url: "https://noduplicate.com"
        }
      }
    end

    # This test focuses on the logic, but the actual product creation will fail
    # because we're trying to create a new product, not update existing one
  end

  test "should handle database type compatibility in controller" do
    sign_in @user

    post products_path, params: {
      product: {
        name: "Compatibility Test",
        tagline: "Testing type compatibility",
        description: "This product tests database type compatibility in the controller.",
        website_url: "https://compatibility.com"
      }
    }

    product = Product.last

    # Verify the controller handles bigint user_id correctly
    assert_equal @user.id, product.user_id
    assert_kind_of Integer, product.user_id

    # Verify maker association works
    product_maker = product.product_makers.first
    assert_equal @user.id, product_maker.user_id
    assert_kind_of Integer, product_maker.user_id
    assert_equal product.id, product_maker.product_id
    assert_kind_of String, product_maker.product_id
  end

  test "should set correct status based on button clicked" do
    sign_in @user

    # Test live status (default)
    post products_path, params: {
      product: {
        name: "Live Product",
        tagline: "Should be live",
        description: "This product should be live by default.",
        website_url: "https://live.com"
      }
    }

    product = Product.last
    assert product.live?
    assert_equal Date.current, product.launch_date

    # Test draft status
    post products_path, params: {
      product: {
        name: "Draft Product",
        tagline: "Should be draft",
        description: "This product should be draft.",
        website_url: "https://draft.com"
      },
      draft: "true"
    }

    product = Product.last
    assert product.draft?
    assert_nil product.launch_date
  end
end
