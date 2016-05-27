class AddProgressToClientEmailLog < ActiveRecord::Migration
  def change
    add_column :client_email_logs, :progress, :integer, default: 0
  end
end
