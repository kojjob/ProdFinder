# frozen_string_literal: true

require "test_helper"

class TopicTest < ActiveSupport::TestCase
  def setup
    @topic = Topic.new(
      name: "Artificial Intelligence",
      description: "Everything related to AI, machine learning, and automation technologies."
    )
  end

  test "should be valid with valid attributes" do
    assert @topic.valid?
  end

  test "should require name" do
    @topic.name = ""
    assert_not @topic.valid?
    assert_includes @topic.errors[:name], "can't be blank"
  end

  test "should require description" do
    @topic.description = ""
    assert_not @topic.valid?
    assert_includes @topic.errors[:description], "can't be blank"
  end

  test "should validate name length" do
    @topic.name = "ab" # too short
    assert_not @topic.valid?

    @topic.name = "a" * 101 # too long
    assert_not @topic.valid?

    @topic.name = "Valid Name"
    assert @topic.valid?
  end

  test "should validate description length" do
    @topic.description = "Too short"
    assert_not @topic.valid?

    @topic.description = "a" * 1001 # too long
    assert_not @topic.valid?

    @topic.description = "This is a valid description that meets the minimum length requirement for testing purposes."
    assert @topic.valid?
  end

  test "should validate unique name" do
    @topic.name = "Technology"
    @topic.save!

    duplicate_topic = Topic.new(
      name: "Technology",
      description: "Another description about technology"
    )
    assert_not duplicate_topic.valid?
  end

  test "should validate unique slug" do
    @topic.slug = "artificial-intelligence"
    @topic.save!

    duplicate_topic = Topic.new(
      name: "Artificial Intelligence",
      description: "Another description",
      slug: "artificial-intelligence"
    )
    assert_not duplicate_topic.valid?
  end

  test "should have default values" do
    topic = Topic.new(
      name: "Test Topic",
      description: "Test description that is long enough to meet the minimum requirement"
    )

    assert_equal 0, topic.products_count
    assert_equal 0, topic.followers_count
  end

  test "should have associations" do
    assert_respond_to @topic, :product_topics
    assert_respond_to @topic, :products
    assert_respond_to @topic, :topic_follows
    assert_respond_to @topic, :followers
  end

  test "should generate slug automatically" do
    topic = Topic.new(
      name: "Web Development",
      description: "Everything related to web development technologies and frameworks."
    )
    topic.valid?
    assert_equal "web-development", topic.slug
  end

  test "should generate unique slug for duplicate names" do
    existing_topic = Topic.create!(
      name: "Web Development",
      description: "First description about web development",
      slug: "web-development"
    )

    new_topic = Topic.new(
      name: "Web Development",
      description: "Second description about web development"
    )
    new_topic.valid?
    assert_equal "web-development-1", new_topic.slug
  end

  test "should normalize name" do
    topic = Topic.new(
      name: "  DATA SCIENCE  ",
      description: "Valid description that is long enough to meet the minimum requirement"
    )
    topic.valid?
    assert_equal "Data Science", topic.name
    assert_equal "data-science", topic.slug
  end

  test "should have enum status" do
    assert_respond_to Topic, :active
    assert_respond_to Topic, :inactive
  end

  test "should know if active" do
    @topic.status = :active
    assert @topic.active?
    assert_not @topic.inactive?
  end

  test "should know if inactive" do
    @topic.status = :inactive
    assert @topic.inactive?
    assert_not @topic.active?
  end

  test "should get popular topics" do
    # This test would require fixtures or factory data
    # For now, just test that the scope exists
    assert_respond_to Topic, :popular
  end

  test "should get active topics" do
    active_topic = Topic.create!(
      name: "Active Topic",
      description: "An active topic for testing",
      status: :active
    )
    inactive_topic = Topic.create!(
      name: "Inactive Topic",
      description: "An inactive topic for testing",
      status: :inactive
    )

    active_topics = Topic.active
    assert_includes active_topics, active_topic
    assert_not_includes active_topics, inactive_topic
  end
end
