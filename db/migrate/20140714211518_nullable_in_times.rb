class NullableInTimes < ActiveRecord::Migration
  def change
  	change_column :location_times, :location_id, :integer, :null => true
  	change_column :provider_times, :service_provider_id, :integer, :null => true
  end
end
