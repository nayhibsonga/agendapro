class ChangePresetNotesFromCompanySetting < ActiveRecord::Migration
  def change
    change_column :company_settings, :preset_notes, :text
  end
end
