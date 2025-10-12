class CreateMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :media, id: :uuid do |t|
      t.uuid :product_id, null: false
      t.integer :media_type, null: false, default: 0
      t.string :file_url, null: false
      t.string :thumbnail_url
      t.integer :position, default: 0
      t.string :alt_text
      t.boolean :is_thumbnail, default: false

      t.timestamps
    end
    add_index :media, :product_id
  end
end
