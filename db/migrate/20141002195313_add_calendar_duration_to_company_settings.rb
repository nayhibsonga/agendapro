class AddCalendarDurationToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :calendar_duration, :integer, default: 15
  end
end
