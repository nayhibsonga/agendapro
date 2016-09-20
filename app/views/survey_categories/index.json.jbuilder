json.array!(@survey_categories) do |survey_category|
  json.extract! survey_category, :id, :name, :company_id
  json.url survey_category_url(survey_category, format: :json)
end
