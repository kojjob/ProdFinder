class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name, null: false
      t.string :tagline, null: false
      t.text :description, null: false
      t.string :slug, null: false
      t.string :website_url, null: false
      t.date :launch_date
      t.integer :status, default: 0
      t.datetime :featured_at
      t.date :product_of_day_at
      t.integer :pricing_type, default: 0
      t.boolean :africa_focused, default: true
      t.jsonb :countries_available, default: []
      t.text :maker_comment
      t.integer :upvotes_count, default: 0
      t.integer :comments_count, default: 0
      t.integer :views_count, default: 0
      t.boolean :maker_inside, default: false
      t.uuid :user_id

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :slug, unique: true
    add_index :products, :user_id
    add_index :products, :launch_date
    add_index :products, :product_of_day_at
  end
end
