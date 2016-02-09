require 'rails_helper'

RSpec.describe "attributes/index", :type => :view do
  before(:each) do
    assign(:attributes, [
      Attribute.create!(
        :company_id => 1,
        :name => "Name",
        :description => "MyText",
        :datatype => "Datatype",
        :mandatory => false
      ),
      Attribute.create!(
        :company_id => 1,
        :name => "Name",
        :description => "MyText",
        :datatype => "Datatype",
        :mandatory => false
      )
    ])
  end

  it "renders a list of attributes" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Datatype".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
