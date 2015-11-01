class AddPresetNotesToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :preset_notes, :string
  end
end
