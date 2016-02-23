class AddMonthlyMailsCapacityToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :mails_base_capacity, :integer, default: 0

  	plan_personal = Plan.where(custom: false, name: "Personal").first
  	plan_normal = Plan.where(custom: false, name: "Normal").first
  	plan_premium = Plan.where(custom: false, name: "Premium").first
  	plan_pro = Plan.where(custom: false, name: "Pro").first

  	plan_personal.update_column(:monthly_mails, 2000)
  	plan_normal.update_column(:monthly_mails, 5000)
  	plan_premium.update_column(:monthly_mails, 10000)
  	plan_pro.update_column(:monthly_mails, 15000)

  	Company.all.each do |company|
  		company.company_setting.mails_base_capacity = company.plan.monthly_mails
  		company.company_setting.save
  	end

  end
end
