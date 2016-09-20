class CreateSurveyConstructs < ActiveRecord::Migration
  def change
    create_table :survey_constructs do |t|
      t.string :name

      t.timestamps
    end
  end
end
