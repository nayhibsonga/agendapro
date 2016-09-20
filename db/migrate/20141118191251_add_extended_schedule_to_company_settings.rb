class AddExtendedScheduleToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :extended_schedule_bool, :boolean, default: false
    add_column :company_settings, :extended_min_hour, :time, default: "9:00"
    add_column :company_settings, :extended_max_hour, :time, default: "20:00"
  end
end
