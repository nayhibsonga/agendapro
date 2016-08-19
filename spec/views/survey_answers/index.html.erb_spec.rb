require 'rails_helper'

RSpec.describe "survey_answers/index", :type => :view do
  before(:each) do
    assign(:survey_answers, [
      SurveyAnswer.create!(),
      SurveyAnswer.create!()
    ])
  end

  it "renders a list of survey_answers" do
    render
  end
end
