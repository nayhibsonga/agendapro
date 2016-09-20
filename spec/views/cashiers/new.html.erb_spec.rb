require 'rails_helper'

RSpec.describe "cashiers/new", :type => :view do
  before(:each) do
    assign(:cashier, Cashier.new(
      :company_id => 1,
      :name => "MyString",
      :code => "MyString",
      :active => false
    ))
  end

  it "renders new cashier form" do
    render

    assert_select "form[action=?][method=?]", cashiers_path, "post" do

      assert_select "input#cashier_company_id[name=?]", "cashier[company_id]"

      assert_select "input#cashier_name[name=?]", "cashier[name]"

      assert_select "input#cashier_code[name=?]", "cashier[code]"

      assert_select "input#cashier_active[name=?]", "cashier[active]"
    end
  end
end
