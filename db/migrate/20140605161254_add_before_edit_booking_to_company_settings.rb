class AddBeforeEditBookingToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :before_edit_booking, :integer, :default => 12
  end
end
