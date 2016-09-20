class CreateStockSettingEmails < ActiveRecord::Migration
  def change
    create_table :stock_setting_emails do |t|
      t.integer :stock_alarm_setting_id
      t.string :email

      t.timestamps
    end
  end
end
