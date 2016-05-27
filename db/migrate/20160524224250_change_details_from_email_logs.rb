class ChangeDetailsFromEmailLogs < ActiveRecord::Migration
  def change
    change_column :booking_email_logs, :details, :text
    change_column :client_email_logs, :details, :text
  end
end
