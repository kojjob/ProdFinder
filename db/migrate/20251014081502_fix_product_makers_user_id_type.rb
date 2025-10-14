class FixProductMakersUserIdType < ActiveRecord::Migration[8.1]
  def up
    # Fix product_makers table - drop and recreate user_id column
    if foreign_key_exists?(:product_makers, :users)
      remove_foreign_key :product_makers, :users
    end

    remove_index :product_makers, :user_id if index_exists?(:product_makers, :user_id)
    remove_index :product_makers, [ :product_id, :user_id ], unique: true if index_exists?(:product_makers, [ :product_id, :user_id ], unique: true)

    remove_column :product_makers, :user_id
    add_column :product_makers, :user_id, :bigint, null: false

    add_index :product_makers, :user_id
    add_index :product_makers, [ :product_id, :user_id ], unique: true
    add_foreign_key :product_makers, :users

    # Fix products table - drop and recreate user_id column
    remove_index :products, :user_id if index_exists?(:products, :user_id)
    remove_column :products, :user_id
    add_column :products, :user_id, :bigint
    add_index :products, :user_id
  end

  def down
    # Reverse product_makers changes
    remove_foreign_key :product_makers, :users if foreign_key_exists?(:product_makers, :users)
    remove_index :product_makers, :user_id if index_exists?(:product_makers, :user_id)
    remove_index :product_makers, [ :product_id, :user_id ], unique: true if index_exists?(:product_makers, [ :product_id, :user_id ], unique: true)

    remove_column :product_makers, :user_id
    add_column :product_makers, :user_id, :uuid, null: false

    add_index :product_makers, :user_id
    add_index :product_makers, [ :product_id, :user_id ], unique: true
    add_foreign_key :product_makers, :users

    # Reverse products changes
    remove_index :products, :user_id if index_exists?(:products, :user_id)
    remove_column :products, :user_id
    add_column :products, :user_id, :uuid
    add_index :products, :user_id
  end
end
