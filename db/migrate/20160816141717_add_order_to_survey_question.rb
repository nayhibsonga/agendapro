class AddOrderToSurveyQuestion < ActiveRecord::Migration
  def change
    add_column :survey_questions, :order, :integer
  end
end
