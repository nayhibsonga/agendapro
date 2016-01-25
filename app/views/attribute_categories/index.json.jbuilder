json.array!(@attribute_categories) do |attribute_category|
  json.extract! attribute_category, :id, :attribute_id, :category
  json.url attribute_category_url(attribute_category, format: :json)
end
