require 'rails_helper'

RSpec.describe "cashiers/show", :type => :view do
  before(:each) do
    @cashier = assign(:cashier, Cashier.create!(
      :company_id => 1,
      :name => "Name",
      :code => "Code",
      :active => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Code/)
    expect(rendered).to match(/false/)
  end
end
