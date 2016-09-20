class AddMandatoryMockBookingInfoToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :mandatory_mock_booking_info, :boolean, default: false
  end
end
