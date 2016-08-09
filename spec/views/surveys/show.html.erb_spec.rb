require 'rails_helper'

RSpec.describe "surveys/show", :type => :view do
  before(:each) do
    @survey = assign(:survey, Survey.create!(
      :quality => 1,
      :style => 2,
      :satifaction => 3,
      :comment => "MyText",
      :client => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(//)
  end
end
