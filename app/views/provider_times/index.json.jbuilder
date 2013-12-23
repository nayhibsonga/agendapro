json.array!(@staff_times) do |staff_time|
  json.extract! staff_time, :id
  json.url staff_time_url(staff_time, format: :json)
end
