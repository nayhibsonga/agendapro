class AddTimesToServicePromo < ActiveRecord::Migration
  def change
  	add_column :service_promos, :morning_start, :datetime, null: false, default: "2000-01-01 09:00:00"
  	add_column :service_promos, :morning_end, :datetime, null: false, default: "2000-01-01 12:00:00"
  	add_column :service_promos, :afternoon_start, :datetime, null: false, default: "2000-01-01 12:00:00"
  	add_column :service_promos, :afternoon_end, :datetime, null: false, default: "2000-01-01 18:00:00"
  	add_column :service_promos, :night_start, :datetime, null: false, default: "2000-01-01 18:00:00"
  	add_column :service_promos, :night_end, :datetime, null: false, default: "2000-01-01 20:00:00"
  end
end
