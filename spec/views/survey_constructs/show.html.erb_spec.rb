require 'rails_helper'

RSpec.describe "survey_constructs/show", :type => :view do
  before(:each) do
    @survey_construct = assign(:survey_construct, SurveyConstruct.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
