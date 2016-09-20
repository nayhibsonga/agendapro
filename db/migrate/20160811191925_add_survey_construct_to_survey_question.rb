class AddSurveyConstructToSurveyQuestion < ActiveRecord::Migration
  def change
    add_reference :survey_questions, :survey_construct, index: true
  end
end
