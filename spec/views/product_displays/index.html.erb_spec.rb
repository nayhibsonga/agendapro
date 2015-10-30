require 'rails_helper'

RSpec.describe "product_displays/index", :type => :view do
  before(:each) do
    assign(:product_displays, [
      ProductDisplay.create!(
        :name => "Name",
        :company_id => 1
      ),
      ProductDisplay.create!(
        :name => "Name",
        :company_id => 1
      )
    ])
  end

  it "renders a list of product_displays" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
