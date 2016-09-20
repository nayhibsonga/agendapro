class AddPeriodicSendToStockSetting < ActiveRecord::Migration
  def change
  	add_column :stock_alarm_settings, :periodic_send, :boolean, default: false
  end
end
