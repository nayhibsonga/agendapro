require 'rails_helper'

RSpec.describe "bundles/edit", :type => :view do
  before(:each) do
    @bundle = assign(:bundle, Bundle.create!(
      :name => "MyString",
      :price => "9.99",
      :service_category => nil,
      :description => "MyText"
    ))
  end

  it "renders the edit bundle form" do
    render

    assert_select "form[action=?][method=?]", bundle_path(@bundle), "post" do

      assert_select "input#bundle_name[name=?]", "bundle[name]"

      assert_select "input#bundle_price[name=?]", "bundle[price]"

      assert_select "input#bundle_service_category_id[name=?]", "bundle[service_category_id]"

      assert_select "textarea#bundle_description[name=?]", "bundle[description]"
    end
  end
end
