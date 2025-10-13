class CreateTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :topics, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :icon
      t.string :color
      t.integer :products_count, default: 0, null: false
      t.integer :followers_count, default: 0, null: false
      t.integer :position, default: 0, null: false
      t.boolean :featured, default: false, null: false

      t.timestamps
    end
    add_index :topics, :name, unique: true
    add_index :topics, :slug, unique: true
    add_index :topics, :position
    add_index :topics, :featured
  end
end
