class AddActiveteSurveyToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :activate_survey, :integer
  end
end
