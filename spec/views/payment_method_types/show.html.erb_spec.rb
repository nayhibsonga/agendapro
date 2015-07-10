require 'rails_helper'

RSpec.describe "payment_method_types/show", :type => :view do
  before(:each) do
    @payment_method_type = assign(:payment_method_type, PaymentMethodType.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
