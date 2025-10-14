class CreateBlogComments < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :blog_comments }
      t.text :content
      t.integer :status
      t.integer :upvotes_count

      t.timestamps
    end
  end
end
