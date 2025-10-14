class CreateProductMakers < ActiveRecord::Migration[8.1]
  def change
    create_table :product_makers, id: :uuid do |t|
      t.uuid :product_id, null: false
      t.uuid :user_id, null: false
      t.integer :role, default: 0
      t.boolean :is_hunter, default: false
      t.integer :position, default: 0

      t.timestamps
    end
    add_index :product_makers, :product_id
    add_index :product_makers, :user_id
    add_index :product_makers, [ :product_id, :user_id ], unique: true
  end
end
