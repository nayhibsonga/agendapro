require 'rails_helper'

RSpec.describe "survey_categories/index", :type => :view do
  before(:each) do
    assign(:survey_categories, [
      SurveyCategory.create!(
        :name => "Name",
        :company => nil
      ),
      SurveyCategory.create!(
        :name => "Name",
        :company => nil
      )
    ])
  end

  it "renders a list of survey_categories" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
