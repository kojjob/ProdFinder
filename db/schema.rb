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

ActiveRecord::Schema[8.1].define(version: 2025_10_12_231215) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.string "avatar_url"
    t.text "bio"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.boolean "email_notifications", default: true
    t.integer "followers_count", default: 0
    t.integer "following_count", default: 0
    t.string "full_name", null: false
    t.datetime "last_seen_at"
    t.string "location"
    t.boolean "maker_status", default: false
    t.string "passwordless_token"
    t.datetime "passwordless_token_sent_at"
    t.integer "products_hunted_count", default: 0
    t.integer "products_launched_count", default: 0
    t.datetime "remember_created_at"
    t.integer "reputation_score", default: 0
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
    t.index ["username"], name: "index_users_on_username", unique: true
  end
end
