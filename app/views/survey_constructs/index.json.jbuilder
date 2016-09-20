json.array!(@survey_constructs) do |survey_construct|
  json.extract! survey_construct, :id
  json.url survey_construct_url(survey_construct, format: :json)
end
