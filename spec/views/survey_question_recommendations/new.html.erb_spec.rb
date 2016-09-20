require 'rails_helper'

RSpec.describe "survey_question_recommendations/new", :type => :view do
  before(:each) do
    assign(:survey_question_recommendation, SurveyQuestionRecommendation.new(
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders new survey_question_recommendation form" do
    render

    assert_select "form[action=?][method=?]", survey_question_recommendations_path, "post" do

      assert_select "input#survey_question_recommendation_name[name=?]", "survey_question_recommendation[name]"

      assert_select "input#survey_question_recommendation_description[name=?]", "survey_question_recommendation[description]"
    end
  end
end
