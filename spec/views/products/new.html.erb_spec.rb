require 'rails_helper'

RSpec.describe "products/new", :type => :view do
  before(:each) do
    assign(:product, Product.new(
      :company_id => nil,
      :name => "MyString",
      :price => 1.5,
      :description => "MyText"
    ))
  end

  it "renders new product form" do
    render

    assert_select "form[action=?][method=?]", products_path, "post" do

      assert_select "input#product_company_id_id[name=?]", "product[company_id_id]"

      assert_select "input#product_name[name=?]", "product[name]"

      assert_select "input#product_price[name=?]", "product[price]"

      assert_select "textarea#product_description[name=?]", "product[description]"
    end
  end
end
