require 'rails_helper'

RSpec.describe "payments/new", :type => :view do
  before(:each) do
    assign(:payment, Payment.new(
      :company => nil,
      :amount => 1.5,
      :receipt_type => nil,
      :receipt_number => "MyString",
      :payment_method => nil,
      :payment_method_number => "MyString",
      :payment_method_type => nil,
      :installments => 1,
      :payed => false,
      :bank => nil
    ))
  end

  it "renders new payment form" do
    render

    assert_select "form[action=?][method=?]", payments_path, "post" do

      assert_select "input#payment_company_id[name=?]", "payment[company_id]"

      assert_select "input#payment_amount[name=?]", "payment[amount]"

      assert_select "input#payment_receipt_type_id[name=?]", "payment[receipt_type_id]"

      assert_select "input#payment_receipt_number[name=?]", "payment[receipt_number]"

      assert_select "input#payment_payment_method_id[name=?]", "payment[payment_method_id]"

      assert_select "input#payment_payment_method_number[name=?]", "payment[payment_method_number]"

      assert_select "input#payment_payment_method_type_id[name=?]", "payment[payment_method_type_id]"

      assert_select "input#payment_installments[name=?]", "payment[installments]"

      assert_select "input#payment_payed[name=?]", "payment[payed]"

      assert_select "input#payment_bank_id[name=?]", "payment[bank_id]"
    end
  end
end
