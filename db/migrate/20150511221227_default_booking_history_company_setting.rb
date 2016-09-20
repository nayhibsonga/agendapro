class DefaultBookingHistoryCompanySetting < ActiveRecord::Migration
  def change
    change_column :company_settings, :booking_history, :boolean, default: true
  end
end
