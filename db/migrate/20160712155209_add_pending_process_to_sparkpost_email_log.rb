class AddPendingProcessToSparkpostEmailLog < ActiveRecord::Migration
  def change
    add_column :sparkpost_email_logs, :pending_process, :boolean, default: false
  end
end
