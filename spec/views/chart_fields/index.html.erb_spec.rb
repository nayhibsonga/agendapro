require 'rails_helper'

RSpec.describe "chart_fields/index", :type => :view do
  before(:each) do
    assign(:chart_fields, [
      ChartField.create!(
        :company => nil,
        :chart_group => nil,
        :name => "Name",
        :description => "MyText",
        :datatype => "Datatype",
        :slug => "Slug",
        :mandatory => false,
        :order => 1
      ),
      ChartField.create!(
        :company => nil,
        :chart_group => nil,
        :name => "Name",
        :description => "MyText",
        :datatype => "Datatype",
        :slug => "Slug",
        :mandatory => false,
        :order => 1
      )
    ])
  end

  it "renders a list of chart_fields" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Datatype".to_s, :count => 2
    assert_select "tr>td", :text => "Slug".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
