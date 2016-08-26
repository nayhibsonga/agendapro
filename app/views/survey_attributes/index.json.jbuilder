json.array!(@survey_attributes) do |survey_attribute|
  json.extract! survey_attribute, :id, :name, :description
  json.url survey_attribute_url(survey_attribute, format: :json)
end
