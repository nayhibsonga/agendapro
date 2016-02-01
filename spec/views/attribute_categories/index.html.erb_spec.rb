require 'rails_helper'

RSpec.describe "attribute_categories/index", :type => :view do
  before(:each) do
    assign(:attribute_categories, [
      AttributeCategory.create!(
        :attribute_id => 1,
        :category => "Category"
      ),
      AttributeCategory.create!(
        :attribute_id => 1,
        :category => "Category"
      )
    ])
  end

  it "renders a list of attribute_categories" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Category".to_s, :count => 2
  end
end
