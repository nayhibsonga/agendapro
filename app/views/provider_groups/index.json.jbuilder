json.array!(@provider_groups) do |provider_group|
  json.extract! provider_group, :id, :company_id, :name, :order
  json.url provider_group_url(provider_group, format: :json)
end
