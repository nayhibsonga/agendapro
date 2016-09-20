require 'rails_helper'

RSpec.describe "payment_method_types/new", :type => :view do
  before(:each) do
    assign(:payment_method_type, PaymentMethodType.new(
      :name => "MyString"
    ))
  end

  it "renders new payment_method_type form" do
    render

    assert_select "form[action=?][method=?]", payment_method_types_path, "post" do

      assert_select "input#payment_method_type_name[name=?]", "payment_method_type[name]"
    end
  end
end
