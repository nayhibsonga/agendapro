require 'rails_helper'

RSpec.describe "marketplace_categories/index", :type => :view do
  before(:each) do
    assign(:marketplace_categories, [
      MarketplaceCategory.create!(
        :name => "Name",
        :show_in_marketplace => false
      ),
      MarketplaceCategory.create!(
        :name => "Name",
        :show_in_marketplace => false
      )
    ])
  end

  it "renders a list of marketplace_categories" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
