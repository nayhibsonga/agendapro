require 'rails_helper'

RSpec.describe "survey_attributes/index", :type => :view do
  before(:each) do
    assign(:survey_attributes, [
      SurveyAttribute.create!(
        :name => "Name",
        :description => "Description"
      ),
      SurveyAttribute.create!(
        :name => "Name",
        :description => "Description"
      )
    ])
  end

  it "renders a list of survey_attributes" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
