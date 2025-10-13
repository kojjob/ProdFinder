class CreateSeoMetadata < ActiveRecord::Migration[8.1]
  def change
    create_table :seo_metadata do |t|
      t.references :seoable, polymorphic: true, null: false
      t.string :title
      t.string :description
      t.string :keywords
      t.string :og_title
      t.string :og_description
      t.string :og_image_url
      t.string :twitter_title
      t.string :twitter_description
      t.string :twitter_image_url
      t.string :canonical_url
      t.string :robots
      t.json :json_ld

      t.timestamps
    end
  end
end
