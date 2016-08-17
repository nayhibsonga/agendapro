class RemoveHoursToSurveyConstruct < ActiveRecord::Migration
  def change
    remove_column :survey_constructs, :hours, :integer
  end
end
