require 'rails_helper'

RSpec.describe "survey_constructs/index", :type => :view do
  before(:each) do
    assign(:survey_constructs, [
      SurveyConstruct.create!(),
      SurveyConstruct.create!()
    ])
  end

  it "renders a list of survey_constructs" do
    render
  end
end
