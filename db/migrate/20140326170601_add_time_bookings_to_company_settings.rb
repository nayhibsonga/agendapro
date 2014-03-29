class AddTimeBookingsToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :before_booking, :integer, null: false, default: 24
    add_column :company_settings, :after_booking, :integer, null: false, default: 6
  end
end
