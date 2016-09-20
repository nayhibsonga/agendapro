require 'rails_helper'

RSpec.describe "chart_groups/new", :type => :view do
  before(:each) do
    assign(:chart_group, ChartGroup.new(
      :company => nil,
      :name => "MyString",
      :order => 1
    ))
  end

  it "renders new chart_group form" do
    render

    assert_select "form[action=?][method=?]", chart_groups_path, "post" do

      assert_select "input#chart_group_company_id[name=?]", "chart_group[company_id]"

      assert_select "input#chart_group_name[name=?]", "chart_group[name]"

      assert_select "input#chart_group_order[name=?]", "chart_group[order]"
    end
  end
end
