class AddMonthlyMailsCapacityToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :mails_base_capacity, :integer, default: 0

  	Company.all.each do |company|
  		company.company_setting.mails_base_capacity = company.plan.monthly_mails
  		company.company_setting.save
  	end

  end
end
