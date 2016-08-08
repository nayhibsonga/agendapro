json.array!(@surveys) do |survey|
  json.extract! survey, :id, :quality, :style, :satisfaction, :comment, :client_id
  json.url survey_url(survey, format: :json)
end
