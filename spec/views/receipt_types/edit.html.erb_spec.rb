require 'rails_helper'

RSpec.describe "receipt_types/edit", :type => :view do
  before(:each) do
    @receipt_type = assign(:receipt_type, ReceiptType.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit receipt_type form" do
    render

    assert_select "form[action=?][method=?]", receipt_type_path(@receipt_type), "post" do

      assert_select "input#receipt_type_name[name=?]", "receipt_type[name]"
    end
  end
end
