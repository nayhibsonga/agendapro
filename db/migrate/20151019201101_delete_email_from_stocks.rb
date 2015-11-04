class DeleteEmailFromStocks < ActiveRecord::Migration
  def change
  	remove_column :stock_alarm_settings, :email, :string
  	remove_column :location_products, :alarm_email, :string
  end
end
