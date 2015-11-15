require 'rails_helper'

RSpec.describe "product_displays/show", :type => :view do
  before(:each) do
    @product_display = assign(:product_display, ProductDisplay.create!(
      :name => "Name",
      :company_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
  end
end
