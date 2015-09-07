require 'rails_helper'

RSpec.describe "provider_groups/show", :type => :view do
  before(:each) do
    @provider_group = assign(:provider_group, ProviderGroup.create!(
      :company => nil,
      :name => "Name",
      :order => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
  end
end
