json.array!(@payment_method_types) do |payment_method_type|
  json.extract! payment_method_type, :id, :name
  json.url payment_method_type_url(payment_method_type, format: :json)
end
