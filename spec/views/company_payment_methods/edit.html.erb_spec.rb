require 'rails_helper'

RSpec.describe "company_payment_methods/edit", :type => :view do
  before(:each) do
    @company_payment_method = assign(:company_payment_method, CompanyPaymentMethod.create!(
      :name => "MyString",
      :company => nil
    ))
  end

  it "renders the edit company_payment_method form" do
    render

    assert_select "form[action=?][method=?]", company_payment_method_path(@company_payment_method), "post" do

      assert_select "input#company_payment_method_name[name=?]", "company_payment_method[name]"

      assert_select "input#company_payment_method_company_id[name=?]", "company_payment_method[company_id]"
    end
  end
end
