require 'rails_helper'

RSpec.describe "cashiers/index", :type => :view do
  before(:each) do
    assign(:cashiers, [
      Cashier.create!(
        :company_id => 1,
        :name => "Name",
        :code => "Code",
        :active => false
      ),
      Cashier.create!(
        :company_id => 1,
        :name => "Name",
        :code => "Code",
        :active => false
      )
    ])
  end

  it "renders a list of cashiers" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Code".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
