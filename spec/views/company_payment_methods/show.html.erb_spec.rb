require 'rails_helper'

RSpec.describe "company_payment_methods/show", :type => :view do
  before(:each) do
    @company_payment_method = assign(:company_payment_method, CompanyPaymentMethod.create!(
      :name => "Name",
      :company => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
  end
end
