require 'rails_helper'

RSpec.describe "attributes/new", :type => :view do
  before(:each) do
    assign(:attribute, Attribute.new(
      :company_id => 1,
      :name => "MyString",
      :description => "MyText",
      :datatype => "MyString",
      :mandatory => false
    ))
  end

  it "renders new attribute form" do
    render

    assert_select "form[action=?][method=?]", attributes_path, "post" do

      assert_select "input#attribute_company_id[name=?]", "attribute[company_id]"

      assert_select "input#attribute_name[name=?]", "attribute[name]"

      assert_select "textarea#attribute_description[name=?]", "attribute[description]"

      assert_select "input#attribute_datatype[name=?]", "attribute[datatype]"

      assert_select "input#attribute_mandatory[name=?]", "attribute[mandatory]"
    end
  end
end
