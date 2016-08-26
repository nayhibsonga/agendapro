class CreateSurveyAttributes < ActiveRecord::Migration
  def change
    create_table :survey_attributes do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
