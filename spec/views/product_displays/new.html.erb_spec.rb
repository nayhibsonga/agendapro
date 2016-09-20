require 'rails_helper'

RSpec.describe "product_displays/new", :type => :view do
  before(:each) do
    assign(:product_display, ProductDisplay.new(
      :name => "MyString",
      :company_id => 1
    ))
  end

  it "renders new product_display form" do
    render

    assert_select "form[action=?][method=?]", product_displays_path, "post" do

      assert_select "input#product_display_name[name=?]", "product_display[name]"

      assert_select "input#product_display_company_id[name=?]", "product_display[company_id]"
    end
  end
end
