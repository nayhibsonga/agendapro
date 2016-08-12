require 'rails_helper'

RSpec.describe "survey_constructs/edit", :type => :view do
  before(:each) do
    @survey_construct = assign(:survey_construct, SurveyConstruct.create!())
  end

  it "renders the edit survey_construct form" do
    render

    assert_select "form[action=?][method=?]", survey_construct_path(@survey_construct), "post" do
    end
  end
end
