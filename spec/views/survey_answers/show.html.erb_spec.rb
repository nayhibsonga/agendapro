require 'rails_helper'

RSpec.describe "survey_answers/show", :type => :view do
  before(:each) do
    @survey_answer = assign(:survey_answer, SurveyAnswer.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
