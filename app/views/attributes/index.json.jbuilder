json.array!(@attributes) do |attribute|
  json.extract! attribute, :id, :company_id, :name, :description, :datatype, :mandatory
  json.url attribute_url(attribute, format: :json)
end
