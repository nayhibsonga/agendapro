class AddActivateToSurveyQuestion < ActiveRecord::Migration
  def change
    add_column :survey_questions, :activate, :boolean
  end
end
