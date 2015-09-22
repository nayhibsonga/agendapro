require 'rails_helper'

RSpec.describe "provider_groups/new", :type => :view do
  before(:each) do
    assign(:provider_group, ProviderGroup.new(
      :company => nil,
      :name => "MyString",
      :order => 1
    ))
  end

  it "renders new provider_group form" do
    render

    assert_select "form[action=?][method=?]", provider_groups_path, "post" do

      assert_select "input#provider_group_company_id[name=?]", "provider_group[company_id]"

      assert_select "input#provider_group_name[name=?]", "provider_group[name]"

      assert_select "input#provider_group_order[name=?]", "provider_group[order]"
    end
  end
end
