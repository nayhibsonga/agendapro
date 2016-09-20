class AddCompanyToSurveyQuestion < ActiveRecord::Migration
  def change
    add_reference :survey_questions, :company, index: true
  end
end
