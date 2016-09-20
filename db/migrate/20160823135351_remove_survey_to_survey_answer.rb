class RemoveSurveyToSurveyAnswer < ActiveRecord::Migration
  def change
    remove_reference :survey_answers, :survey, index: true
  end
end
