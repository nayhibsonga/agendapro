class AddMaxChangesToBookingsAndCompanySettings < ActiveRecord::Migration
  def change
    add_column :bookings, :max_changes, :integer, default: 2
    add_column :company_settings, :max_changes, :integer, default: 2
  end
end
