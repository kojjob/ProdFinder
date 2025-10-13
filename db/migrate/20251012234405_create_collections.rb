class CreateCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :collections, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.string :cover_image_url
      t.boolean :featured, default: false, null: false
      t.integer :products_count, default: 0, null: false
      t.integer :followers_count, default: 0, null: false
      t.integer :upvotes_count, default: 0, null: false
      t.integer :visibility, default: 0, null: false

      t.timestamps
    end
    add_index :collections, :slug, unique: true
    add_index :collections, :featured
    add_index :collections, :visibility
  end
end
