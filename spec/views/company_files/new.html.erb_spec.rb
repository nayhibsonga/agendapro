require 'rails_helper'

RSpec.describe "company_files/new", :type => :view do
  before(:each) do
    assign(:company_file, CompanyFile.new(
      :company_id => "",
      :name => "",
      :full_path => "",
      :public_url => "MyText",
      :size => "",
      :description => "MyText"
    ))
  end

  it "renders new company_file form" do
    render

    assert_select "form[action=?][method=?]", company_files_path, "post" do

      assert_select "input#company_file_company_id[name=?]", "company_file[company_id]"

      assert_select "input#company_file_name[name=?]", "company_file[name]"

      assert_select "input#company_file_full_path[name=?]", "company_file[full_path]"

      assert_select "textarea#company_file_public_url[name=?]", "company_file[public_url]"

      assert_select "input#company_file_size[name=?]", "company_file[size]"

      assert_select "textarea#company_file_description[name=?]", "company_file[description]"
    end
  end
end
