require 'rails_helper'

RSpec.describe "survey_categories/new", :type => :view do
  before(:each) do
    assign(:survey_category, SurveyCategory.new(
      :name => "MyString",
      :company => nil
    ))
  end

  it "renders new survey_category form" do
    render

    assert_select "form[action=?][method=?]", survey_categories_path, "post" do

      assert_select "input#survey_category_name[name=?]", "survey_category[name]"

      assert_select "input#survey_category_company_id[name=?]", "survey_category[company_id]"
    end
  end
end
