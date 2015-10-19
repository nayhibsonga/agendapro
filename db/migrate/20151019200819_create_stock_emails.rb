class CreateStockEmails < ActiveRecord::Migration
  def change
    create_table :stock_emails do |t|
      t.integer :location_product_id
      t.string :email

      t.timestamps
    end
  end
end
