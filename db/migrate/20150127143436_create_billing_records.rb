class CreateBillingRecords < ActiveRecord::Migration
  def change
    create_table :billing_records do |t|
      t.integer :company_id
      t.float :amount
      t.date :date

      t.timestamps
    end
  end
end
