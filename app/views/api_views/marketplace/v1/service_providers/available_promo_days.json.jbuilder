json.array!(@results) do |result|
  json.date result["day_date"]
  json.available result["available_day"]
  json.promo result["available_promotion"]
end