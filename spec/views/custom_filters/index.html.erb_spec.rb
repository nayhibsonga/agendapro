require 'rails_helper'

RSpec.describe "custom_filters/index", :type => :view do
  before(:each) do
    assign(:custom_filters, [
      CustomFilter.create!(
        :company_id => 1,
        :name => "Name"
      ),
      CustomFilter.create!(
        :company_id => 1,
        :name => "Name"
      )
    ])
  end

  it "renders a list of custom_filters" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
