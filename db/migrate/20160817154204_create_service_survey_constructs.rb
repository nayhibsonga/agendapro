class CreateServiceSurveyConstructs < ActiveRecord::Migration
  def change
    create_table :service_survey_constructs do |t|
      t.references :service, index: true
      t.references :survey_construct, index: true

      t.timestamps
    end
  end
end
