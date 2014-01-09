class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name, :null => false
      t.string :web_address, :null => false
      t.string :logo
      t.float :pay_due, :default => 0
      t.references :economic_sector, :index => true, :null => false
      t.references :plan, :index => true, :null => false
      t.references :payment_status, :index => true, :null => false

      t.timestamps
    end
  end
end
