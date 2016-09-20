class AddBookingConfirmationTimeToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :booking_confirmation_time, :integer, default: 1, null: false
  end
end
