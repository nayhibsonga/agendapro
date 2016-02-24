require 'rails_helper'

RSpec.describe "attribute_groups/show", :type => :view do
  before(:each) do
    @attribute_group = assign(:attribute_group, AttributeGroup.create!(
      :company_id => 1,
      :name => "Name",
      :order => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
  end
end
