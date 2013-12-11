json.array!(@location_times) do |location_time|
  json.extract! location_time, :id
  json.url location_time_url(location_time, format: :json)
end
