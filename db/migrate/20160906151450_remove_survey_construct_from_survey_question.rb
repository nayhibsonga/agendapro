class RemoveSurveyConstructFromSurveyQuestion < ActiveRecord::Migration
  def change
    remove_reference :survey_questions, :survey_construct, index: true
  end
end
