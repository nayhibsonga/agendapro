class AddEmailToStockAlarms < ActiveRecord::Migration
  def change
  	add_column :stock_alarm_settings, :email, :string, default: ""
  end
end
