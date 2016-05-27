class AddProgressToBookingEmailLog < ActiveRecord::Migration
  def change
    add_column :booking_email_logs, :progress, :integer, default: 0
  end
end
