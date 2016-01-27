require 'rails_helper'

RSpec.describe "custom_filters/show", :type => :view do
  before(:each) do
    @custom_filter = assign(:custom_filter, CustomFilter.create!(
      :company_id => 1,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Name/)
  end
end
