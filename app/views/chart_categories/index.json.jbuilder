json.array!(@chart_categories) do |chart_category|
  json.extract! chart_category, :id, :chart_field_id, :name
  json.url chart_category_url(chart_category, format: :json)
end
