require 'rails_helper'

RSpec.describe "receipt_types/new", :type => :view do
  before(:each) do
    assign(:receipt_type, ReceiptType.new(
      :name => "MyString"
    ))
  end

  it "renders new receipt_type form" do
    render

    assert_select "form[action=?][method=?]", receipt_types_path, "post" do

      assert_select "input#receipt_type_name[name=?]", "receipt_type[name]"
    end
  end
end
