class AddMonthlyMailsToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :monthly_mails, :integer, default: 0, null: false
  end
end
