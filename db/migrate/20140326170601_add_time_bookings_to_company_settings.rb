class AddTimeBookingsToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :before_booking, :integer, null: false
    add_column :company_settings, :after_booking, :integer, null: false
  end
end
