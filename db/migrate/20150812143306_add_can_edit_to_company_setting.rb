class AddCanEditToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :can_edit, :boolean, default: true
  end
end
