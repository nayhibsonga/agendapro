require 'rails_helper'

RSpec.describe "chart_fields/new", :type => :view do
  before(:each) do
    assign(:chart_field, ChartField.new(
      :company => nil,
      :chart_group => nil,
      :name => "MyString",
      :description => "MyText",
      :datatype => "MyString",
      :slug => "MyString",
      :mandatory => false,
      :order => 1
    ))
  end

  it "renders new chart_field form" do
    render

    assert_select "form[action=?][method=?]", chart_fields_path, "post" do

      assert_select "input#chart_field_company_id[name=?]", "chart_field[company_id]"

      assert_select "input#chart_field_chart_group_id[name=?]", "chart_field[chart_group_id]"

      assert_select "input#chart_field_name[name=?]", "chart_field[name]"

      assert_select "textarea#chart_field_description[name=?]", "chart_field[description]"

      assert_select "input#chart_field_datatype[name=?]", "chart_field[datatype]"

      assert_select "input#chart_field_slug[name=?]", "chart_field[slug]"

      assert_select "input#chart_field_mandatory[name=?]", "chart_field[mandatory]"

      assert_select "input#chart_field_order[name=?]", "chart_field[order]"
    end
  end
end
