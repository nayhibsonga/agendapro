require 'rails_helper'

RSpec.describe "survey_constructs/new", :type => :view do
  before(:each) do
    assign(:survey_construct, SurveyConstruct.new())
  end

  it "renders new survey_construct form" do
    render

    assert_select "form[action=?][method=?]", survey_constructs_path, "post" do
    end
  end
end
