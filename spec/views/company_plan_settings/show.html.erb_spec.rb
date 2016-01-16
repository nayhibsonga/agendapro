require 'rails_helper'

RSpec.describe "company_plan_settings/show", :type => :view do
  before(:each) do
    @company_plan_setting = assign(:company_plan_setting, CompanyPlanSetting.create!(
      :company_id => 1,
      :base_price => 1.5,
      :locations_multiplier => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/1.5/)
  end
end
