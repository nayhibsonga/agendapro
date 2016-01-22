require 'rails_helper'

RSpec.describe "receipt_types/show", :type => :view do
  before(:each) do
    @receipt_type = assign(:receipt_type, ReceiptType.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
