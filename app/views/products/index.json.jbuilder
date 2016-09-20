json.array!(@products) do |product|
  json.extract! product, :id, :company_id_id, :name, :price, :description
  json.url product_url(product, format: :json)
end
