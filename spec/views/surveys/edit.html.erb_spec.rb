require 'rails_helper'

RSpec.describe "surveys/edit", :type => :view do
  before(:each) do
    @survey = assign(:survey, Survey.create!(
      :quality => 1,
      :style => 1,
      :satifaction => 1,
      :comment => "MyText",
      :client => nil
    ))
  end

  it "renders the edit survey form" do
    render

    assert_select "form[action=?][method=?]", survey_path(@survey), "post" do

      assert_select "input#survey_quality[name=?]", "survey[quality]"

      assert_select "input#survey_style[name=?]", "survey[style]"

      assert_select "input#survey_satifaction[name=?]", "survey[satifaction]"

      assert_select "textarea#survey_comment[name=?]", "survey[comment]"

      assert_select "input#survey_client_id[name=?]", "survey[client_id]"
    end
  end
end
