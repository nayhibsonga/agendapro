require 'rails_helper'

RSpec.describe "attributes/show", :type => :view do
  before(:each) do
    @attribute = assign(:attribute, Attribute.create!(
      :company_id => 1,
      :name => "Name",
      :description => "MyText",
      :datatype => "Datatype",
      :mandatory => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Datatype/)
    expect(rendered).to match(/false/)
  end
end
