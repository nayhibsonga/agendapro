require 'rails_helper'

RSpec.describe "surveys/index", :type => :view do
  before(:each) do
    assign(:surveys, [
      Survey.create!(
        :quality => 1,
        :style => 2,
        :satifaction => 3,
        :comment => "MyText",
        :client => nil
      ),
      Survey.create!(
        :quality => 1,
        :style => 2,
        :satifaction => 3,
        :comment => "MyText",
        :client => nil
      )
    ])
  end

  it "renders a list of surveys" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
