class AddDetailsToEmailLogs < ActiveRecord::Migration
  def change
    add_column :booking_email_logs, :details, :string, default: ''
    add_column :client_email_logs, :details, :string, default: ''
  end
end
