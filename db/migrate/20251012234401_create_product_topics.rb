class CreateProductTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :product_topics, id: :uuid do |t|
      t.uuid :product_id, null: false
      t.uuid :topic_id, null: false

      t.timestamps
    end
    add_index :product_topics, :product_id
    add_index :product_topics, :topic_id
    add_index :product_topics, [ :product_id, :topic_id ], unique: true

    add_foreign_key :product_topics, :products, on_delete: :cascade
    add_foreign_key :product_topics, :topics, on_delete: :cascade
  end
end
