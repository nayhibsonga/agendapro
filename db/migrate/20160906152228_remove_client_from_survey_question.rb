class RemoveClientFromSurveyQuestion < ActiveRecord::Migration
  def change
    remove_reference :survey_questions, :client, index: true
  end
end
