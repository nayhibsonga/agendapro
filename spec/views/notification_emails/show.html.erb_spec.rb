require 'rails_helper'

RSpec.describe "notification_emails/show", :type => :view do
  before(:each) do
    @notification_email = assign(:notification_email, NotificationEmail.create!(
      :company => nil,
      :emails => "Emails",
      :notification_type => 1,
      :receptor_type => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Emails/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
