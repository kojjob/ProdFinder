class CreateFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :follows, id: :uuid do |t|
      t.uuid :follower_id, null: false
      t.string :follower_type, null: false
      t.uuid :followee_id, null: false
      t.string :followee_type, null: false

      t.timestamps
    end
    add_index :follows, [ :follower_id, :follower_type ]
    add_index :follows, [ :followee_id, :followee_type ]
    add_index :follows, [ :follower_id, :follower_type, :followee_id, :followee_type ],
              unique: true, name: 'index_follows_uniqueness'
    add_index :follows, :created_at
  end
end
