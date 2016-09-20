class AddBookingHistoryToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :booking_history, :boolean, default: false
    add_column :company_settings, :staff_code, :boolean, default: false
  end
end
