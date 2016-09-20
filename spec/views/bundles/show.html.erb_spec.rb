require 'rails_helper'

RSpec.describe "bundles/show", :type => :view do
  before(:each) do
    @bundle = assign(:bundle, Bundle.create!(
      :name => "Name",
      :price => "9.99",
      :service_category => nil,
      :description => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
  end
end
