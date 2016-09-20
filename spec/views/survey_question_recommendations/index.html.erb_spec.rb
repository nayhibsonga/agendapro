require 'rails_helper'

RSpec.describe "survey_question_recommendations/index", :type => :view do
  before(:each) do
    assign(:survey_question_recommendations, [
      SurveyQuestionRecommendation.create!(
        :name => "Name",
        :description => "Description"
      ),
      SurveyQuestionRecommendation.create!(
        :name => "Name",
        :description => "Description"
      )
    ])
  end

  it "renders a list of survey_question_recommendations" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
