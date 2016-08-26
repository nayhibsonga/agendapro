class AddSurveyQuestionToSurveyAnswer < ActiveRecord::Migration
  def change
    add_reference :survey_answers, :survey_question, index: true
  end
end
