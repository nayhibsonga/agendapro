require 'rails_helper'

RSpec.describe "client_files/index", :type => :view do
  before(:each) do
    assign(:client_files, [
      ClientFile.create!(
        :client_id => "",
        :name => "",
        :full_path => "",
        :public_url => "MyText",
        :size => "",
        :description => "MyText"
      ),
      ClientFile.create!(
        :client_id => "",
        :name => "",
        :full_path => "",
        :public_url => "MyText",
        :size => "",
        :description => "MyText"
      )
    ])
  end

  it "renders a list of client_files" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
