require 'rails_helper'

RSpec.describe "survey_categories/show", :type => :view do
  before(:each) do
    @survey_category = assign(:survey_category, SurveyCategory.create!(
      :name => "Name",
      :company => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
  end
end
