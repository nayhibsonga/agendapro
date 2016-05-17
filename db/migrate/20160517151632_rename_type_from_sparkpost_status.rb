class RenameTypeFromSparkpostStatus < ActiveRecord::Migration
  def change
    rename_column :sparkpost_statuses, :type, :event_type
  end
end
