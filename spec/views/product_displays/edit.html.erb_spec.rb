require 'rails_helper'

RSpec.describe "product_displays/edit", :type => :view do
  before(:each) do
    @product_display = assign(:product_display, ProductDisplay.create!(
      :name => "MyString",
      :company_id => 1
    ))
  end

  it "renders the edit product_display form" do
    render

    assert_select "form[action=?][method=?]", product_display_path(@product_display), "post" do

      assert_select "input#product_display_name[name=?]", "product_display[name]"

      assert_select "input#product_display_company_id[name=?]", "product_display[company_id]"
    end
  end
end
