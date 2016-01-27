require 'rails_helper'

RSpec.describe "custom_filters/new", :type => :view do
  before(:each) do
    assign(:custom_filter, CustomFilter.new(
      :company_id => 1,
      :name => "MyString"
    ))
  end

  it "renders new custom_filter form" do
    render

    assert_select "form[action=?][method=?]", custom_filters_path, "post" do

      assert_select "input#custom_filter_company_id[name=?]", "custom_filter[company_id]"

      assert_select "input#custom_filter_name[name=?]", "custom_filter[name]"
    end
  end
end
