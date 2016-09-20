require 'rails_helper'

RSpec.describe "notification_emails/new", :type => :view do
  before(:each) do
    assign(:notification_email, NotificationEmail.new(
      :company => nil,
      :emails => "MyString",
      :notification_type => 1,
      :receptor_type => 1
    ))
  end

  it "renders new notification_email form" do
    render

    assert_select "form[action=?][method=?]", notification_emails_path, "post" do

      assert_select "input#notification_email_company_id[name=?]", "notification_email[company_id]"

      assert_select "input#notification_email_emails[name=?]", "notification_email[emails]"

      assert_select "input#notification_email_notification_type[name=?]", "notification_email[notification_type]"

      assert_select "input#notification_email_receptor_type[name=?]", "notification_email[receptor_type]"
    end
  end
end
