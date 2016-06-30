require 'rails_helper'

RSpec.describe "chart_groups/index", :type => :view do
  before(:each) do
    assign(:chart_groups, [
      ChartGroup.create!(
        :company => nil,
        :name => "Name",
        :order => 1
      ),
      ChartGroup.create!(
        :company => nil,
        :name => "Name",
        :order => 1
      )
    ])
  end

  it "renders a list of chart_groups" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
