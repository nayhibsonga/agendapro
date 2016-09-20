require 'rails_helper'

RSpec.describe "payment_method_types/edit", :type => :view do
  before(:each) do
    @payment_method_type = assign(:payment_method_type, PaymentMethodType.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit payment_method_type form" do
    render

    assert_select "form[action=?][method=?]", payment_method_type_path(@payment_method_type), "post" do

      assert_select "input#payment_method_type_name[name=?]", "payment_method_type[name]"
    end
  end
end
