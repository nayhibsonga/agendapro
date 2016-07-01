require 'rails_helper'

RSpec.describe "chart_fields/show", :type => :view do
  before(:each) do
    @chart_field = assign(:chart_field, ChartField.create!(
      :company => nil,
      :chart_group => nil,
      :name => "Name",
      :description => "MyText",
      :datatype => "Datatype",
      :slug => "Slug",
      :mandatory => false,
      :order => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Datatype/)
    expect(rendered).to match(/Slug/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/1/)
  end
end
