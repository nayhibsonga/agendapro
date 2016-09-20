require 'rails_helper'

RSpec.describe "NotificationEmails", :type => :request do
  describe "GET /notification_emails" do
    it "works! (now write some real specs)" do
      get notification_emails_path
      expect(response.status).to be(200)
    end
  end
end
