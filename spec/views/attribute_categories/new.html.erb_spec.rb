require 'rails_helper'

RSpec.describe "attribute_categories/new", :type => :view do
  before(:each) do
    assign(:attribute_category, AttributeCategory.new(
      :attribute_id => 1,
      :category => "MyString"
    ))
  end

  it "renders new attribute_category form" do
    render

    assert_select "form[action=?][method=?]", attribute_categories_path, "post" do

      assert_select "input#attribute_category_attribute_id[name=?]", "attribute_category[attribute_id]"

      assert_select "input#attribute_category_category[name=?]", "attribute_category[category]"
    end
  end
end
