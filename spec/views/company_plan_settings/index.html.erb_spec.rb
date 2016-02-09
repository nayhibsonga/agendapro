require 'rails_helper'

RSpec.describe "company_plan_settings/index", :type => :view do
  before(:each) do
    assign(:company_plan_settings, [
      CompanyPlanSetting.create!(
        :company_id => 1,
        :base_price => 1.5,
        :locations_multiplier => 1.5
      ),
      CompanyPlanSetting.create!(
        :company_id => 1,
        :base_price => 1.5,
        :locations_multiplier => 1.5
      )
    ])
  end

  it "renders a list of company_plan_settings" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
