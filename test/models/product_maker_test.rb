# frozen_string_literal: true

require "test_helper"

class ProductMakerTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @product = products(:one)
    @product_maker = ProductMaker.new(
      product: @product,
      user: @user,
      role: :founder,
      position: 0
    )
  end

  test "should be valid with all attributes" do
    assert @product_maker.valid?
  end

  test "should require a product" do
    @product_maker.product = nil
    assert_not @product_maker.valid?
    assert_includes @product_maker.errors[:product], "must exist"
  end

  test "should require a user" do
    @product_maker.user = nil
    assert_not @product_maker.valid?
    assert_includes @product_maker.errors[:user], "must exist"
  end

  test "should raise error for invalid role" do
    assert_raises(ArgumentError) do
      @product_maker.role = :invalid_role
    end
  end

test "should accept valid roles" do
    [ :founder, :co_founder, :team_member ].each do |role|
      @product_maker.role = role
      assert @product_maker.valid?, "Role #{role} should be valid"
    end
  end

  test "should have default position" do
    product_maker = ProductMaker.new(
      product: @product,
      user: @user,
      role: :founder
    )
    assert_equal 0, product_maker.position
  end

  test "should have default is_hunter" do
    product_maker = ProductMaker.new(
      product: @product,
      user: @user,
      role: :founder
    )
    assert_not product_maker.is_hunter
  end

  test "should belong to product" do
    assert_respond_to @product_maker, :product
    assert_equal @product, @product_maker.product
  end

  test "should belong to user" do
    assert_respond_to @product_maker, :user
    assert_equal @user, @product_maker.user
  end

  test "should enforce unique product-user combination" do
    @product_maker.save!
    duplicate = ProductMaker.new(
      product: @product,
      user: @user,
      role: :co_founder
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:product_id], "has already been taken"
  end

test "should allow same user for different products" do
    @product_maker.save!
    other_product = products(:two)

    new_maker = ProductMaker.new(
      product: other_product,
      user: @user,
      role: :founder
    )
    assert new_maker.valid?
  end

test "should allow different users for same product" do
    @product_maker.save!
    other_user = users(:two)

    new_maker = ProductMaker.new(
      product: @product,
      user: other_user,
      role: :co_founder
    )
    assert new_maker.valid?
  end

  test "should handle bigint user_id correctly" do
    @product_maker.save!

    # Verify user_id is stored as integer (bigint)
    assert_equal @user.id, @product_maker.user_id
    assert_kind_of Integer, @product_maker.user_id

    # Verify association works
    assert_equal @user, @product_maker.user
  end

  test "should handle uuid product_id correctly" do
    @product_maker.save!

    # Verify product_id is stored as UUID
    assert_equal @product.id, @product_maker.product_id
    assert_kind_of String, @product_maker.product_id

    # Verify association works
    assert_equal @product, @product_maker.product
  end
end
