class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :web_address
      t.string :logo
      t.float :pay_due
      t.integer :economic_sector_id
      t.integer :plan_id
      t.integer :payment_status_id

      t.timestamps
    end
  end
end
