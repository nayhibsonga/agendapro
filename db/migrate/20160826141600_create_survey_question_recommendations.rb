class CreateSurveyQuestionRecommendations < ActiveRecord::Migration
  def change
    create_table :survey_question_recommendations do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
