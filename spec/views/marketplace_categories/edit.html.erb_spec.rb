require 'rails_helper'

RSpec.describe "marketplace_categories/edit", :type => :view do
  before(:each) do
    @marketplace_category = assign(:marketplace_category, MarketplaceCategory.create!(
      :name => "MyString",
      :show_in_marketplace => false
    ))
  end

  it "renders the edit marketplace_category form" do
    render

    assert_select "form[action=?][method=?]", marketplace_category_path(@marketplace_category), "post" do

      assert_select "input#marketplace_category_name[name=?]", "marketplace_category[name]"

      assert_select "input#marketplace_category_show_in_marketplace[name=?]", "marketplace_category[show_in_marketplace]"
    end
  end
end
