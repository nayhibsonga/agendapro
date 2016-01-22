class CreateSalesCashLogs < ActiveRecord::Migration
  def change
    create_table :sales_cash_logs do |t|
      t.integer :sales_cash_id
      t.datetime :start_date
      t.datetime :end_date
      t.float :remaining_amount

      t.timestamps
    end
  end
end
