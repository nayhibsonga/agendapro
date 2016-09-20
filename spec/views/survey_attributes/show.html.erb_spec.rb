require 'rails_helper'

RSpec.describe "survey_attributes/show", :type => :view do
  before(:each) do
    @survey_attribute = assign(:survey_attribute, SurveyAttribute.create!(
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
