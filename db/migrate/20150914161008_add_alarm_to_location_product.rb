class AddAlarmToLocationProduct < ActiveRecord::Migration
  def change
  	add_column :locations, :default_stock_limit, :integer, default: 0
  	add_column :location_products, :stock_limit, :integer
  	add_column :location_products, :alarm_email, :string
  end
end
