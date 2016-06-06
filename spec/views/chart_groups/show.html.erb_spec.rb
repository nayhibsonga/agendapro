require 'rails_helper'

RSpec.describe "chart_groups/show", :type => :view do
  before(:each) do
    @chart_group = assign(:chart_group, ChartGroup.create!(
      :company => nil,
      :name => "Name",
      :order => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
  end
end
