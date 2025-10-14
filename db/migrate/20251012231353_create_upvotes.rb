class CreateUpvotes < ActiveRecord::Migration[8.1]
  def change
    create_table :upvotes, id: :uuid do |t|
      t.uuid :product_id, null: false
      t.uuid :user_id, null: false

      t.timestamps
    end
    add_index :upvotes, :product_id
    add_index :upvotes, :user_id
    add_index :upvotes, :created_at
    add_index :upvotes, [ :product_id, :user_id ], unique: true
  end
end
