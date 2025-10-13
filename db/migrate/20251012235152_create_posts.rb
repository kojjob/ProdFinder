class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.string :excerpt
      t.references :author, polymorphic: true, null: false
      t.integer :status
      t.datetime :published_at
      t.boolean :featured
      t.datetime :featured_at
      t.integer :views_count
      t.integer :comments_count
      t.integer :reading_time
      t.text :tags
      t.string :meta_title
      t.string :meta_description
      t.string :og_image_url
      t.string :canonical_url

      t.timestamps
    end
    add_index :posts, :title, unique: true
    add_index :posts, :slug, unique: true
  end
end
