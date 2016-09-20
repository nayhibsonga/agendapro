class CreateSurveyQuestionConstructs < ActiveRecord::Migration
  def change
    create_table :survey_question_constructs do |t|
      t.references :survey_question, index: true
      t.references :survey_construct, index: true

      t.timestamps
    end
  end
end
