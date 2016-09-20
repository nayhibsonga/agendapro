require 'rails_helper'

RSpec.describe "survey_attributes/edit", :type => :view do
  before(:each) do
    @survey_attribute = assign(:survey_attribute, SurveyAttribute.create!(
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit survey_attribute form" do
    render

    assert_select "form[action=?][method=?]", survey_attribute_path(@survey_attribute), "post" do

      assert_select "input#survey_attribute_name[name=?]", "survey_attribute[name]"

      assert_select "input#survey_attribute_description[name=?]", "survey_attribute[description]"
    end
  end
end
