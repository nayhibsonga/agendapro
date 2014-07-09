json.array!(@numeric_parameters) do |numeric_parameter|
  json.extract! numeric_parameter, :id, :name, :value
  json.url numeric_parameter_url(numeric_parameter, format: :json)
end
