require 'rails_helper'

RSpec.describe "employee_codes/show", :type => :view do
  before(:each) do
    @employee_code = assign(:employee_code, EmployeeCode.create!(
      :name => "Name",
      :code => "Code",
      :company => nil,
      :active => false,
      :staff => false,
      :cashier => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Code/)
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
  end
end
