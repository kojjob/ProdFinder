class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.references :parent, foreign_key: { to_table: :categories }
      t.integer :posts_count
      t.integer :position
      t.boolean :featured

      t.timestamps
    end
    add_index :categories, :name, unique: true
    add_index :categories, :slug, unique: true
  end
end
