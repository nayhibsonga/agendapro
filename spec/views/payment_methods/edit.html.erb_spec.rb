require 'rails_helper'

RSpec.describe "payment_methods/edit", :type => :view do
  before(:each) do
    @payment_method = assign(:payment_method, PaymentMethod.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit payment_method form" do
    render

    assert_select "form[action=?][method=?]", payment_method_path(@payment_method), "post" do

      assert_select "input#payment_method_name[name=?]", "payment_method[name]"
    end
  end
end
