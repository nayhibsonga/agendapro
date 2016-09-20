class AddStrictBookingToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :strict_booking, :boolean, default: false, null: false
  end
end
