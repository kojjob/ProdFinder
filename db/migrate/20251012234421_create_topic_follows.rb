class CreateTopicFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :topic_follows, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.uuid :topic_id, null: false

      t.timestamps
    end
    add_index :topic_follows, :topic_id
    add_index :topic_follows, [ :user_id, :topic_id ], unique: true

    add_foreign_key :topic_follows, :topics, on_delete: :cascade
  end
end
