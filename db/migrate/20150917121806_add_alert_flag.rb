class AddAlertFlag < ActiveRecord::Migration
  def change
  	add_column :location_products, :alert_flag, :boolean, default: true
  end
end
