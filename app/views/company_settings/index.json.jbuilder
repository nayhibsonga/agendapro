json.array!(@company_settings) do |company_setting|
  json.extract! company_setting, :id
  json.url company_setting_url(company_setting, format: :json)
end
