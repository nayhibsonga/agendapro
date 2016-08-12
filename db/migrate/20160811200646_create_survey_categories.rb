class CreateSurveyCategories < ActiveRecord::Migration
  def change
    create_table :survey_categories do |t|
      t.string :name
      t.references :company, index: true

      t.timestamps
    end
  end
end
