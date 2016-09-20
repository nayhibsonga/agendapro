json.array!(@marketplace_categories) do |marketplace_category|
  json.extract! marketplace_category, :id, :name, :show_in_marketplace
  json.url marketplace_category_url(marketplace_category, format: :json)
end
