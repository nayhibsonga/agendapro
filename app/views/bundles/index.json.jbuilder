json.array!(@bundles) do |bundle|
  json.extract! bundle, :id, :name, :price, :service_category_id, :description
  json.url bundle_url(bundle, format: :json)
end
