require 'rails_helper'

RSpec.describe "client_files/show", :type => :view do
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

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
  end
end
