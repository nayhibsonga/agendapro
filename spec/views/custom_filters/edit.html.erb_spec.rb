require 'rails_helper'

RSpec.describe "custom_filters/edit", :type => :view do
  before(:each) do
    @custom_filter = assign(:custom_filter, CustomFilter.create!(
      :company_id => 1,
      :name => "MyString"
    ))
  end

  it "renders the edit custom_filter form" do
    render

    assert_select "form[action=?][method=?]", custom_filter_path(@custom_filter), "post" do

      assert_select "input#custom_filter_company_id[name=?]", "custom_filter[company_id]"

      assert_select "input#custom_filter_name[name=?]", "custom_filter[name]"
    end
  end
end
