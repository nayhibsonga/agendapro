class ChangeBookingTimesToCompanySetting < ActiveRecord::Migration
  def change
  	change_column :company_settings, :before_booking, :integer, null: false, default: 3
    change_column :company_settings, :after_booking, :integer, null: false, default: 3
    change_column :company_settings, :before_edit_booking, :integer, default: 3
  end
end
