class AddEnhancedFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string, null: false
    add_index :users, :username, unique: true
    add_column :users, :full_name, :string, null: false
    add_column :users, :bio, :text
    add_column :users, :avatar_url, :string
    add_column :users, :website_url, :string
    add_column :users, :twitter_handle, :string
    add_column :users, :location, :string
    add_column :users, :country_code, :string
    add_index :users, :country_code
    add_column :users, :timezone, :string, default: 'Africa/Accra'
    add_column :users, :reputation_score, :integer, default: 0
    add_column :users, :maker_status, :boolean, default: false
    add_column :users, :admin, :boolean, default: false
    add_column :users, :verified, :boolean, default: false
    add_column :users, :email_notifications, :boolean, default: true
    add_column :users, :products_launched_count, :integer, default: 0
    add_column :users, :products_hunted_count, :integer, default: 0
    add_column :users, :upvotes_given_count, :integer, default: 0
    add_column :users, :followers_count, :integer, default: 0
    add_column :users, :following_count, :integer, default: 0
    add_column :users, :last_seen_at, :datetime
    add_column :users, :username_changed_at, :datetime
  end
end
