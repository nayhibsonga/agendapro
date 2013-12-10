json.array!(@districts) do |district|
  json.extract! district, :id
  json.url district_url(district, format: :json)
end
