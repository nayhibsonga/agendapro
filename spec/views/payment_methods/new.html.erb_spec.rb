require 'rails_helper'

RSpec.describe "payment_methods/new", :type => :view do
  before(:each) do
    assign(:payment_method, PaymentMethod.new(
      :name => "MyString"
    ))
  end

  it "renders new payment_method form" do
    render

    assert_select "form[action=?][method=?]", payment_methods_path, "post" do

      assert_select "input#payment_method_name[name=?]", "payment_method[name]"
    end
  end
end
