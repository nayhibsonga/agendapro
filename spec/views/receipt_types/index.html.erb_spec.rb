require 'rails_helper'

RSpec.describe "receipt_types/index", :type => :view do
  before(:each) do
    assign(:receipt_types, [
      ReceiptType.create!(
        :name => "Name"
      ),
      ReceiptType.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of receipt_types" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
