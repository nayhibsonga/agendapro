class AddCompanyToSurveyConstruct < ActiveRecord::Migration
  def change
    add_reference :survey_constructs, :company, index: true
  end
end
