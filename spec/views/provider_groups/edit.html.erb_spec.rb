require 'rails_helper'

RSpec.describe "provider_groups/edit", :type => :view do
  before(:each) do
    @provider_group = assign(:provider_group, ProviderGroup.create!(
      :company => nil,
      :name => "MyString",
      :order => 1
    ))
  end

  it "renders the edit provider_group form" do
    render

    assert_select "form[action=?][method=?]", provider_group_path(@provider_group), "post" do

      assert_select "input#provider_group_company_id[name=?]", "provider_group[company_id]"

      assert_select "input#provider_group_name[name=?]", "provider_group[name]"

      assert_select "input#provider_group_order[name=?]", "provider_group[order]"
    end
  end
end
