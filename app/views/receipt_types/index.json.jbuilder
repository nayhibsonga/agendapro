json.array!(@receipt_types) do |receipt_type|
  json.extract! receipt_type, :id, :name
  json.url receipt_type_url(receipt_type, format: :json)
end
