# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_10_12_235209) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "blog_comments", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "parent_id"
    t.bigint "post_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.integer "upvotes_count"
    t.bigint "user_id", null: false
    t.index ["parent_id"], name: "index_blog_comments_on_parent_id"
    t.index ["post_id"], name: "index_blog_comments_on_post_id"
    t.index ["user_id"], name: "index_blog_comments_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured"
    t.string "name"
    t.bigint "parent_id"
    t.integer "position"
    t.integer "posts_count"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "collection_products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "added_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "collection_id", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.integer "position", default: 0, null: false
    t.uuid "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id", "product_id"], name: "index_collection_products_on_collection_id_and_product_id", unique: true
    t.index ["collection_id"], name: "index_collection_products_on_collection_id"
    t.index ["position"], name: "index_collection_products_on_position"
    t.index ["product_id"], name: "index_collection_products_on_product_id"
  end

  create_table "collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.boolean "featured", default: false, null: false
    t.integer "followers_count", default: 0, null: false
    t.string "name", null: false
    t.integer "products_count", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes_count", default: 0, null: false
    t.bigint "user_id", null: false
    t.integer "visibility", default: 0, null: false
    t.index ["featured"], name: "index_collections_on_featured"
    t.index ["slug"], name: "index_collections_on_slug", unique: true
    t.index ["user_id"], name: "index_collections_on_user_id"
    t.index ["visibility"], name: "index_collections_on_visibility"
  end

  create_table "comment_upvotes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "comment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["comment_id", "user_id"], name: "index_comment_upvotes_on_comment_id_and_user_id", unique: true
    t.index ["comment_id"], name: "index_comment_upvotes_on_comment_id"
    t.index ["user_id"], name: "index_comment_upvotes_on_user_id"
  end

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "edited_at"
    t.uuid "parent_id"
    t.uuid "product_id", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes_count", default: 0
    t.uuid "user_id", null: false
    t.index ["deleted_at"], name: "index_comments_on_deleted_at"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["product_id", "created_at"], name: "index_comments_on_product_id_and_created_at"
    t.index ["product_id"], name: "index_comments_on_product_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "follows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "followee_id", null: false
    t.string "followee_type", null: false
    t.uuid "follower_id", null: false
    t.string "follower_type", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_follows_on_created_at"
    t.index ["followee_id", "followee_type"], name: "index_follows_on_followee_id_and_followee_type"
    t.index ["follower_id", "follower_type", "followee_id", "followee_type"], name: "index_follows_uniqueness", unique: true
    t.index ["follower_id", "follower_type"], name: "index_follows_on_follower_id_and_follower_type"
  end

  create_table "media", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.string "file_url", null: false
    t.boolean "is_thumbnail", default: false
    t.integer "media_type", default: 0, null: false
    t.integer "position", default: 0
    t.uuid "product_id", null: false
    t.string "thumbnail_url"
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_media_on_product_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action_url"
    t.bigint "actor_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "email_sent_at"
    t.uuid "notifiable_id"
    t.string "notifiable_type"
    t.integer "notification_type", null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["user_id", "read_at", "created_at"], name: "index_notifications_for_unread"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "post_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.bigint "post_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_post_categories_on_category_id"
    t.index ["post_id"], name: "index_post_categories_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.string "author_type", null: false
    t.string "canonical_url"
    t.integer "comments_count"
    t.text "content"
    t.datetime "created_at", null: false
    t.string "excerpt"
    t.boolean "featured"
    t.datetime "featured_at"
    t.string "meta_description"
    t.string "meta_title"
    t.string "og_image_url"
    t.datetime "published_at"
    t.integer "reading_time"
    t.string "slug"
    t.integer "status"
    t.text "tags"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "views_count"
    t.index ["author_type", "author_id"], name: "index_posts_on_author"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["title"], name: "index_posts_on_title", unique: true
  end

  create_table "product_makers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_hunter", default: false
    t.integer "position", default: 0
    t.uuid "product_id", null: false
    t.integer "role", default: 0
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["product_id", "user_id"], name: "index_product_makers_on_product_id_and_user_id", unique: true
    t.index ["product_id"], name: "index_product_makers_on_product_id"
    t.index ["user_id"], name: "index_product_makers_on_user_id"
  end

  create_table "product_topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "product_id", null: false
    t.uuid "topic_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "topic_id"], name: "index_product_topics_on_product_id_and_topic_id", unique: true
    t.index ["product_id"], name: "index_product_topics_on_product_id"
    t.index ["topic_id"], name: "index_product_topics_on_topic_id"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "africa_focused", default: true
    t.integer "comments_count", default: 0
    t.jsonb "countries_available", default: []
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.datetime "featured_at"
    t.date "launch_date"
    t.text "maker_comment"
    t.boolean "maker_inside", default: false
    t.string "name", null: false
    t.integer "pricing_type", default: 0
    t.date "product_of_day_at"
    t.string "slug", null: false
    t.integer "status", default: 0
    t.string "tagline", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes_count", default: 0
    t.uuid "user_id"
    t.integer "views_count", default: 0
    t.string "website_url", null: false
    t.index ["launch_date"], name: "index_products_on_launch_date"
    t.index ["name"], name: "index_products_on_name"
    t.index ["product_of_day_at"], name: "index_products_on_product_of_day_at"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "redirects", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "from_path"
    t.integer "status_code"
    t.string "to_path"
    t.datetime "updated_at", null: false
    t.index ["from_path"], name: "index_redirects_on_from_path", unique: true
  end

  create_table "seo_metadata", force: :cascade do |t|
    t.string "canonical_url"
    t.datetime "created_at", null: false
    t.string "description"
    t.json "json_ld"
    t.string "keywords"
    t.string "og_description"
    t.string "og_image_url"
    t.string "og_title"
    t.string "robots"
    t.bigint "seoable_id", null: false
    t.string "seoable_type", null: false
    t.string "title"
    t.string "twitter_description"
    t.string "twitter_image_url"
    t.string "twitter_title"
    t.datetime "updated_at", null: false
    t.index ["seoable_type", "seoable_id"], name: "index_seo_metadata_on_seoable"
  end

  create_table "sitemaps", force: :cascade do |t|
    t.string "changefreq"
    t.datetime "created_at", null: false
    t.datetime "lastmod"
    t.decimal "priority"
    t.integer "sitemap_type"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["url"], name: "index_sitemaps_on_url", unique: true
  end

  create_table "topic_follows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "topic_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["topic_id"], name: "index_topic_follows_on_topic_id"
    t.index ["user_id", "topic_id"], name: "index_topic_follows_on_user_id_and_topic_id", unique: true
    t.index ["user_id"], name: "index_topic_follows_on_user_id"
  end

  create_table "topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured", default: false, null: false
    t.integer "followers_count", default: 0, null: false
    t.string "icon"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.integer "products_count", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["featured"], name: "index_topics_on_featured"
    t.index ["name"], name: "index_topics_on_name", unique: true
    t.index ["position"], name: "index_topics_on_position"
    t.index ["slug"], name: "index_topics_on_slug", unique: true
  end

  create_table "upvotes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "product_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["created_at"], name: "index_upvotes_on_created_at"
    t.index ["product_id", "user_id"], name: "index_upvotes_on_product_id_and_user_id", unique: true
    t.index ["product_id"], name: "index_upvotes_on_product_id"
    t.index ["user_id"], name: "index_upvotes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.string "avatar_url"
    t.text "bio"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.boolean "email_notifications", default: true
    t.string "encrypted_password", default: "", null: false
    t.integer "followers_count", default: 0
    t.integer "following_count", default: 0
    t.string "full_name", null: false
    t.datetime "last_seen_at"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "location"
    t.boolean "maker_status", default: false
    t.string "passwordless_token"
    t.datetime "passwordless_token_sent_at"
    t.integer "products_hunted_count", default: 0
    t.integer "products_launched_count", default: 0
    t.datetime "remember_created_at"
    t.integer "reputation_score", default: 0
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0
    t.string "timezone", default: "Africa/Accra"
    t.string "twitter_handle"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.integer "upvotes_given_count", default: 0
    t.string "username", null: false
    t.datetime "username_changed_at"
    t.boolean "verified", default: false
    t.string "website_url"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["country_code"], name: "index_users_on_country_code"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "blog_comments", "blog_comments", column: "parent_id"
  add_foreign_key "blog_comments", "posts"
  add_foreign_key "blog_comments", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "collection_products", "collections", on_delete: :cascade
  add_foreign_key "collection_products", "products", on_delete: :cascade
  add_foreign_key "collections", "users"
  add_foreign_key "notifications", "users", column: "actor_id", on_delete: :nullify
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "post_categories", "categories"
  add_foreign_key "post_categories", "posts"
  add_foreign_key "product_topics", "products", on_delete: :cascade
  add_foreign_key "product_topics", "topics", on_delete: :cascade
  add_foreign_key "topic_follows", "topics", on_delete: :cascade
  add_foreign_key "topic_follows", "users"
end
