require 'rails_helper'

RSpec.describe "client_files/edit", :type => :view do
  before(:each) do
    @client_file = assign(:client_file, ClientFile.create!(
      :client_id => "",
      :name => "",
      :full_path => "",
      :public_url => "MyText",
      :size => "",
      :description => "MyText"
    ))
  end

  it "renders the edit client_file form" do
    render

    assert_select "form[action=?][method=?]", client_file_path(@client_file), "post" do

      assert_select "input#client_file_client_id[name=?]", "client_file[client_id]"

      assert_select "input#client_file_name[name=?]", "client_file[name]"

      assert_select "input#client_file_full_path[name=?]", "client_file[full_path]"

      assert_select "textarea#client_file_public_url[name=?]", "client_file[public_url]"

      assert_select "input#client_file_size[name=?]", "client_file[size]"

      assert_select "textarea#client_file_description[name=?]", "client_file[description]"
    end
  end
end
