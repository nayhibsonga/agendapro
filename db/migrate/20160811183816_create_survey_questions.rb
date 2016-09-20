class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.string :question
      t.text :description
      t.string :type

      t.timestamps
    end
  end
end
