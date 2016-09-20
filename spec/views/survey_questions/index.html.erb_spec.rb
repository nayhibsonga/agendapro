require 'rails_helper'

RSpec.describe "survey_questions/index", :type => :view do
  before(:each) do
    assign(:survey_questions, [
      SurveyQuestion.create!(),
      SurveyQuestion.create!()
    ])
  end

  it "renders a list of survey_questions" do
    render
  end
end
