require 'rails_helper'

RSpec.describe "attribute_groups/new", :type => :view do
  before(:each) do
    assign(:attribute_group, AttributeGroup.new(
      :company_id => 1,
      :name => "MyString",
      :order => 1
    ))
  end

  it "renders new attribute_group form" do
    render

    assert_select "form[action=?][method=?]", attribute_groups_path, "post" do

      assert_select "input#attribute_group_company_id[name=?]", "attribute_group[company_id]"

      assert_select "input#attribute_group_name[name=?]", "attribute_group[name]"

      assert_select "input#attribute_group_order[name=?]", "attribute_group[order]"
    end
  end
end
