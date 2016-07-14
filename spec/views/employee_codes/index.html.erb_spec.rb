require 'rails_helper'

RSpec.describe "employee_codes/index", :type => :view do
  before(:each) do
    assign(:employee_codes, [
      EmployeeCode.create!(
        :name => "Name",
        :code => "Code",
        :company => nil,
        :active => false,
        :staff => false,
        :cashier => false
      ),
      EmployeeCode.create!(
        :name => "Name",
        :code => "Code",
        :company => nil,
        :active => false,
        :staff => false,
        :cashier => false
      )
    ])
  end

  it "renders a list of employee_codes" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Code".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
