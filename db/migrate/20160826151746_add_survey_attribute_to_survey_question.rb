class AddSurveyAttributeToSurveyQuestion < ActiveRecord::Migration
  def change
    add_reference :survey_questions, :survey_attribute, index: true
  end
end
