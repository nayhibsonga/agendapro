require 'rails_helper'

RSpec.describe "company_payment_methods/index", :type => :view do
  before(:each) do
    assign(:company_payment_methods, [
      CompanyPaymentMethod.create!(
        :name => "Name",
        :company => nil
      ),
      CompanyPaymentMethod.create!(
        :name => "Name",
        :company => nil
      )
    ])
  end

  it "renders a list of company_payment_methods" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
