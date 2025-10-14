class CreateSitemaps < ActiveRecord::Migration[8.1]
  def change
    create_table :sitemaps do |t|
      t.string :url
      t.decimal :priority
      t.string :changefreq
      t.datetime :lastmod
      t.integer :sitemap_type

      t.timestamps
    end
    add_index :sitemaps, :url, unique: true
  end
end
