class CreateSparkpostEmailLogs < ActiveRecord::Migration
  def change
    create_table :sparkpost_email_logs do |t|
      t.text :raw_message

      t.timestamps
    end
  end
end
