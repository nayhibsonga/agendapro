require 'rails_helper'

RSpec.describe "survey_question_constructs/show", :type => :view do
  before(:each) do
    @survey_question_construct = assign(:survey_question_construct, SurveyQuestionConstruct.create!(
      :survey_question => nil,
      :survey_construct => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
