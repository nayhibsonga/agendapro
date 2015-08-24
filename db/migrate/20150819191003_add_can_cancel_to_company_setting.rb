class AddCanCancelToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :can_cancel, :boolean, default: true
  end
end
