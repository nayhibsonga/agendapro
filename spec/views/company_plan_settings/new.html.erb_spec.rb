require 'rails_helper'

RSpec.describe "company_plan_settings/new", :type => :view do
  before(:each) do
    assign(:company_plan_setting, CompanyPlanSetting.new(
      :company_id => 1,
      :base_price => 1.5,
      :locations_multiplier => 1.5
    ))
  end

  it "renders new company_plan_setting form" do
    render

    assert_select "form[action=?][method=?]", company_plan_settings_path, "post" do

      assert_select "input#company_plan_setting_company_id[name=?]", "company_plan_setting[company_id]"

      assert_select "input#company_plan_setting_base_price[name=?]", "company_plan_setting[base_price]"

      assert_select "input#company_plan_setting_locations_multiplier[name=?]", "company_plan_setting[locations_multiplier]"
    end
  end
end
