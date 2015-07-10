require 'rails_helper'

RSpec.describe "payments/index", :type => :view do
  before(:each) do
    assign(:payments, [
      Payment.create!(
        :company => nil,
        :amount => 1.5,
        :receipt_type => nil,
        :receipt_number => "Receipt Number",
        :payment_method => nil,
        :payment_method_number => "Payment Method Number",
        :payment_method_type => nil,
        :installments => 1,
        :payed => false,
        :bank => nil
      ),
      Payment.create!(
        :company => nil,
        :amount => 1.5,
        :receipt_type => nil,
        :receipt_number => "Receipt Number",
        :payment_method => nil,
        :payment_method_number => "Payment Method Number",
        :payment_method_type => nil,
        :installments => 1,
        :payed => false,
        :bank => nil
      )
    ])
  end

  it "renders a list of payments" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Receipt Number".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Payment Method Number".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
