class AddAfterSurveyToCompanySetting < ActiveRecord::Migration
  def change
    add_column :company_settings, :after_survey, :integer
  end
end
