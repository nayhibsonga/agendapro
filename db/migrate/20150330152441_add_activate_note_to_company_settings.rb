class AddActivateNoteToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :activate_notes, :boolean, default: true, null: false
  end
end
