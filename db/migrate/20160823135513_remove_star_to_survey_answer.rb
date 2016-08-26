class RemoveStarToSurveyAnswer < ActiveRecord::Migration
  def change
    remove_column :survey_answers, :stars, :integer
  end
end
