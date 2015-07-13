require 'rails_helper'

RSpec.describe "payments/show", :type => :view do
  before(:each) do
    @payment = assign(:payment, Payment.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Receipt Number/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Payment Method Number/)
    expect(rendered).to match(//)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(//)
  end
end
