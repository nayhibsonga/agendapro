require 'rails_helper'

RSpec.describe "attribute_groups/edit", :type => :view do
  before(:each) do
    @attribute_group = assign(:attribute_group, AttributeGroup.create!(
      :company_id => 1,
      :name => "MyString",
      :order => 1
    ))
  end

  it "renders the edit attribute_group form" do
    render

    assert_select "form[action=?][method=?]", attribute_group_path(@attribute_group), "post" do

      assert_select "input#attribute_group_company_id[name=?]", "attribute_group[company_id]"

      assert_select "input#attribute_group_name[name=?]", "attribute_group[name]"

      assert_select "input#attribute_group_order[name=?]", "attribute_group[order]"
    end
  end
end
