require 'rails_helper'

RSpec.describe "marketplace_categories/show", :type => :view do
  before(:each) do
    @marketplace_category = assign(:marketplace_category, MarketplaceCategory.create!(
      :name => "Name",
      :show_in_marketplace => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/false/)
  end
end
