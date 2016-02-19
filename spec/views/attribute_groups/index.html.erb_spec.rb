require 'rails_helper'

RSpec.describe "attribute_groups/index", :type => :view do
  before(:each) do
    assign(:attribute_groups, [
      AttributeGroup.create!(
        :company_id => 1,
        :name => "Name",
        :order => 2
      ),
      AttributeGroup.create!(
        :company_id => 1,
        :name => "Name",
        :order => 2
      )
    ])
  end

  it "renders a list of attribute_groups" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
