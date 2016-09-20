require 'rails_helper'

RSpec.describe "charts/edit", :type => :view do
  before(:each) do
    @chart = assign(:chart, Chart.create!(
      :company => nil,
      :client => nil,
      :booking => nil,
      :user => nil
    ))
  end

  it "renders the edit chart form" do
    render

    assert_select "form[action=?][method=?]", chart_path(@chart), "post" do

      assert_select "input#chart_company_id[name=?]", "chart[company_id]"

      assert_select "input#chart_client_id[name=?]", "chart[client_id]"

      assert_select "input#chart_booking_id[name=?]", "chart[booking_id]"

      assert_select "input#chart_user_id[name=?]", "chart[user_id]"
    end
  end
end
