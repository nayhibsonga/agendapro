json.array!(@product_displays) do |product_display|
  json.extract! product_display, :id, :name
  json.url product_display_url(product_display, format: :json)
end
