class RemoveAfterSurveyToCompanySetting < ActiveRecord::Migration
  def change
    remove_column :company_settings, :after_survey, :integer
    remove_column :company_settings, :hours_survey, :integer
  end
end
