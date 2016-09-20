require 'rails_helper'

RSpec.describe "company_files/index", :type => :view do
  before(:each) do
    assign(:company_files, [
      CompanyFile.create!(
        :company_id => "",
        :name => "",
        :full_path => "",
        :public_url => "MyText",
        :size => "",
        :description => "MyText"
      ),
      CompanyFile.create!(
        :company_id => "",
        :name => "",
        :full_path => "",
        :public_url => "MyText",
        :size => "",
        :description => "MyText"
      )
    ])
  end

  it "renders a list of company_files" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
