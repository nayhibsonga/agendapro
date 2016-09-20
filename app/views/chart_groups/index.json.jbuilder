json.array!(@chart_groups) do |chart_group|
  json.extract! chart_group, :id, :company_id, :name, :order
  json.url chart_group_url(chart_group, format: :json)
end
