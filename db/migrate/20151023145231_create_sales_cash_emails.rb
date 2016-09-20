class CreateSalesCashEmails < ActiveRecord::Migration
  def change
    create_table :sales_cash_emails do |t|
      t.integer :sales_cash_id
      t.string :email

      t.timestamps
    end
  end
end
