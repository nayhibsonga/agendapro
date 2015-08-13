json.array!(@service_providers) do |service_provider|
  json.extract! service_provider, :id, :public_name
end