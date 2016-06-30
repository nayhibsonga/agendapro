json.array!(@chart_fields) do |chart_field|
  json.extract! chart_field, :id, :company_id, :chart_group_id, :name, :description, :datatype, :slug, :mandatory, :order
  json.url chart_field_url(chart_field, format: :json)
end
