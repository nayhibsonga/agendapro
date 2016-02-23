json.array!(@attribute_groups) do |attribute_group|
  json.extract! attribute_group, :id, :company_id, :name, :order
  json.url attribute_group_url(attribute_group, format: :json)
end
