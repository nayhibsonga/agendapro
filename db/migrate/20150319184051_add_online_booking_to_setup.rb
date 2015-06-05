class AddOnlineBookingToSetup < ActiveRecord::Migration
  def change
  	add_column :locations, :online_booking, :boolean, default: true
  	add_column :service_providers, :online_booking, :boolean, default: true
  	add_column :services, :online_booking, :boolean, default: true
  end
end
