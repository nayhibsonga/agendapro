FactoryGirl.define do
  factory :company_plan_setting, :class => 'CompanyPlanSettings' do
    locations 1
service_providers 1
monthly_mails 1
has_custom_price false
custom_price 1.5
  end

end
