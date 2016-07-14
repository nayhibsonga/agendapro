json.array!(@employee_codes) do |employee_code|
  json.extract! employee_code, :id, :name, :code, :company_id, :active, :staff, :cashier
  json.url employee_code_url(employee_code, format: :json)
end
