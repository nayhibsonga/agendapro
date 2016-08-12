require 'rails_helper'

RSpec.describe "survey_questions/show", :type => :view do
  before(:each) do
    @survey_question = assign(:survey_question, SurveyQuestion.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
