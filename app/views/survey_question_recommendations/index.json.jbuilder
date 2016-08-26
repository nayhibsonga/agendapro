json.array!(@survey_question_recommendations) do |survey_question_recommendation|
  json.extract! survey_question_recommendation, :id, :name, :description
  json.url survey_question_recommendation_url(survey_question_recommendation, format: :json)
end
