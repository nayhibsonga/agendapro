require 'rails_helper'

RSpec.describe "survey_attributes/new", :type => :view do
  before(:each) do
    assign(:survey_attribute, SurveyAttribute.new(
      :name => "MyString",
      :description => "MyString"
    ))
  end

  it "renders new survey_attribute form" do
    render

    assert_select "form[action=?][method=?]", survey_attributes_path, "post" do

      assert_select "input#survey_attribute_name[name=?]", "survey_attribute[name]"

      assert_select "input#survey_attribute_description[name=?]", "survey_attribute[description]"
    end
  end
end
