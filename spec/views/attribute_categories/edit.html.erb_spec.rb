require 'rails_helper'

RSpec.describe "attribute_categories/edit", :type => :view do
  before(:each) do
    @attribute_category = assign(:attribute_category, AttributeCategory.create!(
      :attribute_id => 1,
      :category => "MyString"
    ))
  end

  it "renders the edit attribute_category form" do
    render

    assert_select "form[action=?][method=?]", attribute_category_path(@attribute_category), "post" do

      assert_select "input#attribute_category_attribute_id[name=?]", "attribute_category[attribute_id]"

      assert_select "input#attribute_category_category[name=?]", "attribute_category[category]"
    end
  end
end
