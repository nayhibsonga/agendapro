require 'rails_helper'

RSpec.describe "charts/index", :type => :view do
  before(:each) do
    assign(:charts, [
      Chart.create!(
        :company => nil,
        :client => nil,
        :booking => nil,
        :user => nil
      ),
      Chart.create!(
        :company => nil,
        :client => nil,
        :booking => nil,
        :user => nil
      )
    ])
  end

  it "renders a list of charts" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
