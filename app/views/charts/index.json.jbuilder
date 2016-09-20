json.array!(@charts) do |chart|
  json.extract! chart, :id, :company_id, :client_id, :booking_id, :user_id, :date
  json.url chart_url(chart, format: :json)
end
