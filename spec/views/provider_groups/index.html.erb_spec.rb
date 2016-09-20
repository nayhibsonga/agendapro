require 'rails_helper'

RSpec.describe "provider_groups/index", :type => :view do
  before(:each) do
    assign(:provider_groups, [
      ProviderGroup.create!(
        :company => nil,
        :name => "Name",
        :order => 1
      ),
      ProviderGroup.create!(
        :company => nil,
        :name => "Name",
        :order => 1
      )
    ])
  end

  it "renders a list of provider_groups" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
