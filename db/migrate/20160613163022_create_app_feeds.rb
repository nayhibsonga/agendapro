class CreateAppFeeds < ActiveRecord::Migration
  def change
    create_table :app_feeds do |t|
      t.references :company, index: true
      t.string :title
      t.string :image
      t.text :subtitle
      t.text :body
      t.string :external_url

      t.timestamps
    end
  end
end
