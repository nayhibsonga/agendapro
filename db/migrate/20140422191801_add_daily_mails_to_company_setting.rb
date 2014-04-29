class AddDailyMailsToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :daily_mails, :integer, :default => 50
    add_column :company_settings, :sent_mails, :integer, :default => 0
  end
end
