class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments, id: :uuid do |t|
      t.uuid :product_id, null: false
      t.uuid :user_id, null: false
      t.uuid :parent_id
      t.text :body, null: false
      t.integer :upvotes_count, default: 0
      t.datetime :edited_at
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :comments, :product_id
    add_index :comments, :user_id
    add_index :comments, :parent_id
    add_index :comments, [ :product_id, :created_at ]
    add_index :comments, :deleted_at
  end
end
