require 'rails_helper'

RSpec.describe "survey_categories/edit", :type => :view do
  before(:each) do
    @survey_category = assign(:survey_category, SurveyCategory.create!(
      :name => "MyString",
      :company => nil
    ))
  end

  it "renders the edit survey_category form" do
    render

    assert_select "form[action=?][method=?]", survey_category_path(@survey_category), "post" do

      assert_select "input#survey_category_name[name=?]", "survey_category[name]"

      assert_select "input#survey_category_company_id[name=?]", "survey_category[company_id]"
    end
  end
end
