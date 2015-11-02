class CreateSalesCashes < ActiveRecord::Migration
  def change
    create_table :sales_cashes do |t|
      t.integer :location_id
      t.float :cash, default: 0.0
      t.integer :scheduled_reset_day, default: 1
      t.boolean :scheduled_reset_monthly, default: true
      t.datetime :last_reset_date

      t.timestamps
    end
  end
end
