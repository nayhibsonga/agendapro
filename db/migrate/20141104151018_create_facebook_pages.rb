class CreateFacebookPages < ActiveRecord::Migration
  def change
    create_table :facebook_pages do |t|
      t.references :company, index: true
      t.string :facebook_page_id

      t.timestamps
    end
  end
end
