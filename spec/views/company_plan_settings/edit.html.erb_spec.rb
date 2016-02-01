require 'rails_helper'

RSpec.describe "company_plan_settings/edit", :type => :view do
  before(:each) do
    @company_plan_setting = assign(:company_plan_setting, CompanyPlanSetting.create!(
      :company_id => 1,
      :base_price => 1.5,
      :locations_multiplier => 1.5
    ))
  end

  it "renders the edit company_plan_setting form" do
    render

    assert_select "form[action=?][method=?]", company_plan_setting_path(@company_plan_setting), "post" do

      assert_select "input#company_plan_setting_company_id[name=?]", "company_plan_setting[company_id]"

      assert_select "input#company_plan_setting_base_price[name=?]", "company_plan_setting[base_price]"

      assert_select "input#company_plan_setting_locations_multiplier[name=?]", "company_plan_setting[locations_multiplier]"
    end
  end
end
