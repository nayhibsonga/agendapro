require 'rails_helper'

RSpec.describe "product_categories/index", :type => :view do
  before(:each) do
    assign(:product_categories, [
      ProductCategory.create!(
        :name => "Name"
      ),
      ProductCategory.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of product_categories" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
