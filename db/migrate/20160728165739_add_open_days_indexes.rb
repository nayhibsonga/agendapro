class AddOpenDaysIndexes < ActiveRecord::Migration
  def change
  	add_index :location_open_days, :start_time
  	add_index :location_open_days, :end_time
  	add_index :provider_open_days, :start_time
  	add_index :provider_open_days, :end_time
  end
end
