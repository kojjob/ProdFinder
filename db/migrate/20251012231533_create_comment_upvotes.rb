class CreateCommentUpvotes < ActiveRecord::Migration[8.1]
  def change
    create_table :comment_upvotes, id: :uuid do |t|
      t.uuid :comment_id, null: false
      t.uuid :user_id, null: false

      t.timestamps
    end
    add_index :comment_upvotes, :comment_id
    add_index :comment_upvotes, :user_id
    add_index :comment_upvotes, [ :comment_id, :user_id ], unique: true
  end
end
