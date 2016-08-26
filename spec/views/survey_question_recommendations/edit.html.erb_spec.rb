require 'rails_helper'

RSpec.describe "survey_question_recommendations/edit", :type => :view do
  before(:each) do
    @survey_question_recommendation = assign(:survey_question_recommendation, SurveyQuestionRecommendation.create!(
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit survey_question_recommendation form" do
    render

    assert_select "form[action=?][method=?]", survey_question_recommendation_path(@survey_question_recommendation), "post" do

      assert_select "input#survey_question_recommendation_name[name=?]", "survey_question_recommendation[name]"

      assert_select "input#survey_question_recommendation_description[name=?]", "survey_question_recommendation[description]"
    end
  end
end
