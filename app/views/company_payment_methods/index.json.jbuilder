json.array!(@company_payment_methods) do |company_payment_method|
  json.extract! company_payment_method, :id, :name, :company_id
  json.url company_payment_method_url(company_payment_method, format: :json)
end
