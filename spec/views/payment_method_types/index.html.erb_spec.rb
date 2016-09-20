require 'rails_helper'

RSpec.describe "payment_method_types/index", :type => :view do
  before(:each) do
    assign(:payment_method_types, [
      PaymentMethodType.create!(
        :name => "Name"
      ),
      PaymentMethodType.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of payment_method_types" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
