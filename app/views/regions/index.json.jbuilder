json.array!(@regions) do |region|
  json.extract! region, :id
  json.url region_url(region, format: :json)
end
