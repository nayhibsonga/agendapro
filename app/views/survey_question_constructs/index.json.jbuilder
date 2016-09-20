json.array!(@survey_question_constructs) do |survey_question_construct|
  json.extract! survey_question_construct, :id, :survey_question_id, :survey_construct_id
  json.url survey_question_construct_url(survey_question_construct, format: :json)
end
