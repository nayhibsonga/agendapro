require 'rails_helper'

RSpec.describe "charts/show", :type => :view do
  before(:each) do
    @chart = assign(:chart, Chart.create!(
      :company => nil,
      :client => nil,
      :booking => nil,
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
