json.array!(@company_plan_settings) do |company_plan_setting|
  json.extract! company_plan_setting, :id, :company_id, :base_price, :locations_multiplier
  json.url company_plan_setting_url(company_plan_setting, format: :json)
end
