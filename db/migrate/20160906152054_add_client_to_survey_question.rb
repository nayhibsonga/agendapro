class AddClientToSurveyQuestion < ActiveRecord::Migration
  def change
    add_reference :survey_questions, :client, index: true
  end
end
