class CreateStockAlarmSettings < ActiveRecord::Migration
  def change
    create_table :stock_alarm_settings do |t|
      t.integer :location_id
      t.boolean :quick_send, default: false
      t.boolean :has_default_stock_limit, default: false
      t.integer :default_stock_limit, default: 0
      t.boolean :monthly, default: true
      t.integer :month_day, default: 1
      t.integer :week_day, default: 1

      t.timestamps
    end
  end
end
