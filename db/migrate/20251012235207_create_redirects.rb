class CreateRedirects < ActiveRecord::Migration[8.1]
  def change
    create_table :redirects do |t|
      t.string :from_path
      t.string :to_path
      t.integer :status_code
      t.boolean :active
      t.datetime :expires_at

      t.timestamps
    end
    add_index :redirects, :from_path, unique: true
  end
end
