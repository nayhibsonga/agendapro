json.array!(@custom_filters) do |custom_filter|
  json.extract! custom_filter, :id, :company_id, :name
  json.url custom_filter_url(custom_filter, format: :json)
end
