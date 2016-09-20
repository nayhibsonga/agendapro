require 'rails_helper'

RSpec.describe "survey_question_constructs/index", :type => :view do
  before(:each) do
    assign(:survey_question_constructs, [
      SurveyQuestionConstruct.create!(
        :survey_question => nil,
        :survey_construct => nil
      ),
      SurveyQuestionConstruct.create!(
        :survey_question => nil,
        :survey_construct => nil
      )
    ])
  end

  it "renders a list of survey_question_constructs" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
