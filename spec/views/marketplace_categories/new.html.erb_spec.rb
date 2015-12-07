require 'rails_helper'

RSpec.describe "marketplace_categories/new", :type => :view do
  before(:each) do
    assign(:marketplace_category, MarketplaceCategory.new(
      :name => "MyString",
      :show_in_marketplace => false
    ))
  end

  it "renders new marketplace_category form" do
    render

    assert_select "form[action=?][method=?]", marketplace_categories_path, "post" do

      assert_select "input#marketplace_category_name[name=?]", "marketplace_category[name]"

      assert_select "input#marketplace_category_show_in_marketplace[name=?]", "marketplace_category[show_in_marketplace]"
    end
  end
end
