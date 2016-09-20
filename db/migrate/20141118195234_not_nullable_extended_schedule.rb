class NotNullableExtendedSchedule < ActiveRecord::Migration
  def change
  	change_column :company_settings, :extended_schedule_bool, :boolean, :default => false, :null => false
  	change_column :company_settings, :extended_min_hour, :time, :default => "09:00", :null => false
  	change_column :company_settings, :extended_max_hour, :time, :default => "20:00", :null => false
  end
  CompanySetting.all.each do |company_setting|
  	if company_setting.company
	  	location_ids = company_setting.company.locations.pluck(:id)
		if LocationTime.where(location_id: location_ids).count > 0
			changed = false
			first_open_time = LocationTime.where(location_id: location_ids).order(:open).first.open
			last_close_time = LocationTime.where(location_id: location_ids).order(:close).last.close
			if company_setting.extended_min_hour > first_open_time
				company_setting.extended_min_hour = first_open_time
				changed = true
			end
			if company_setting.extended_max_hour < last_close_time
				company_setting.extended_max_hour = last_close_time
				changed = true
			end
			if changed
				company_setting.save!
			end
		end
	end
  end
end
