class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :actor, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :notifiable_type
      t.uuid :notifiable_id
      t.integer :notification_type, null: false
      t.string :title, null: false
      t.text :body
      t.string :action_url
      t.datetime :read_at
      t.datetime :email_sent_at

      t.timestamps
    end
    add_index :notifications, [ :notifiable_type, :notifiable_id ]
    add_index :notifications, [ :user_id, :read_at, :created_at ],
              name: 'index_notifications_for_unread'
    add_index :notifications, :created_at
  end
end
