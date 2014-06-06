class RemoveDailyMailFromCompanySettings < ActiveRecord::Migration
  def change
    remove_column :company_settings, :daily_mail, :integer
  end
end
