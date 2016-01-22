json.array!(@cashiers) do |cashier|
  json.extract! cashier, :id, :company_id, :name, :code, :active
  json.url cashier_url(cashier, format: :json)
end
