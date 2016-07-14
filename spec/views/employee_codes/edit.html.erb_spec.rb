require 'rails_helper'

RSpec.describe "employee_codes/edit", :type => :view do
  before(:each) do
    @employee_code = assign(:employee_code, EmployeeCode.create!(
      :name => "MyString",
      :code => "MyString",
      :company => nil,
      :active => false,
      :staff => false,
      :cashier => false
    ))
  end

  it "renders the edit employee_code form" do
    render

    assert_select "form[action=?][method=?]", employee_code_path(@employee_code), "post" do

      assert_select "input#employee_code_name[name=?]", "employee_code[name]"

      assert_select "input#employee_code_code[name=?]", "employee_code[code]"

      assert_select "input#employee_code_company_id[name=?]", "employee_code[company_id]"

      assert_select "input#employee_code_active[name=?]", "employee_code[active]"

      assert_select "input#employee_code_staff[name=?]", "employee_code[staff]"

      assert_select "input#employee_code_cashier[name=?]", "employee_code[cashier]"
    end
  end
end
