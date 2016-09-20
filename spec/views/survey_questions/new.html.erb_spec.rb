require 'rails_helper'

RSpec.describe "survey_questions/new", :type => :view do
  before(:each) do
    assign(:survey_question, SurveyQuestion.new())
  end

  it "renders new survey_question form" do
    render

    assert_select "form[action=?][method=?]", survey_questions_path, "post" do
    end
  end
end
