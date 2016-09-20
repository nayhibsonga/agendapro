class ChangeStringFormatInSurveyQuestions < ActiveRecord::Migration
  def change
    remove_column :survey_questions, :type
    add_column :survey_questions, :type_question, :integer
  end
end
