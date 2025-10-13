class CreateCollectionProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_products, id: :uuid do |t|
      t.uuid :collection_id, null: false
      t.uuid :product_id, null: false
      t.integer :position, default: 0, null: false
      t.text :note, limit: 500
      t.datetime :added_at, default: -> { "CURRENT_TIMESTAMP" }, null: false

      t.timestamps
    end
    add_index :collection_products, :collection_id
    add_index :collection_products, :product_id
    add_index :collection_products, [ :collection_id, :product_id ], unique: true
    add_index :collection_products, :position

    add_foreign_key :collection_products, :collections, on_delete: :cascade
    add_foreign_key :collection_products, :products, on_delete: :cascade
  end
end
