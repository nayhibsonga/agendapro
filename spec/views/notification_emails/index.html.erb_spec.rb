require 'rails_helper'

RSpec.describe "notification_emails/index", :type => :view do
  before(:each) do
    assign(:notification_emails, [
      NotificationEmail.create!(
        :company => nil,
        :emails => "Emails",
        :notification_type => 1,
        :receptor_type => 2
      ),
      NotificationEmail.create!(
        :company => nil,
        :emails => "Emails",
        :notification_type => 1,
        :receptor_type => 2
      )
    ])
  end

  it "renders a list of notification_emails" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Emails".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
