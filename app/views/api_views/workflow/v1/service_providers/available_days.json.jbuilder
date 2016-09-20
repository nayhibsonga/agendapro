json.array!(@available_days) do |result|
  json.date result[:date]
  json.available result[:available]
end
