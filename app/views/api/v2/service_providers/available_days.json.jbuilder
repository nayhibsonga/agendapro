json.array!(@available_days) do |available_day|
  json.extract! available_day, :date, :available
end