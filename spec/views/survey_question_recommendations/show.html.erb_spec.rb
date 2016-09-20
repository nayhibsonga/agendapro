require 'rails_helper'

RSpec.describe "survey_question_recommendations/show", :type => :view do
  before(:each) do
    @survey_question_recommendation = assign(:survey_question_recommendation, SurveyQuestionRecommendation.create!(
      :name => "Name",
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
  end
end
