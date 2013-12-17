class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name, :null => false
      t.string :web_address, :null => false
      t.string :logo
      t.float :pay_due
      t.references :economic_sector, :null => false
      t.references :plan, :null => false
      t.references :payment_status, :null => false

      t.timestamps
    end
  end
end
