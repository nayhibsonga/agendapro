require 'rails_helper'

RSpec.describe "survey_questions/edit", :type => :view do
  before(:each) do
    @survey_question = assign(:survey_question, SurveyQuestion.create!())
  end

  it "renders the edit survey_question form" do
    render

    assert_select "form[action=?][method=?]", survey_question_path(@survey_question), "post" do
    end
  end
end
