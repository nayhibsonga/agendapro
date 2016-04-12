class AddAllowsOverlapHoursToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :allows_overlap_hours, :boolean, default: false
  end
end
