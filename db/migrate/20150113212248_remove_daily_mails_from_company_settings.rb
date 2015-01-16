class RemoveDailyMailsFromCompanySettings < ActiveRecord::Migration
  def change
    remove_column :company_settings, :daily_mails, :integer
    remove_column :company_settings, :sent_mails, :integer
  end
end
