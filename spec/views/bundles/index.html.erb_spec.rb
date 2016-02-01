require 'rails_helper'

RSpec.describe "bundles/index", :type => :view do
  before(:each) do
    assign(:bundles, [
      Bundle.create!(
        :name => "Name",
        :price => "9.99",
        :service_category => nil,
        :description => "MyText"
      ),
      Bundle.create!(
        :name => "Name",
        :price => "9.99",
        :service_category => nil,
        :description => "MyText"
      )
    ])
  end

  it "renders a list of bundles" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
