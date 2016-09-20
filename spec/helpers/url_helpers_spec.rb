require 'rails_helper'

describe UrlHelper do
  context "Social urls" do
    it "should return a social uri without subdomain" do

      provider = "facebook"
      provider2 = "google_oauth2"
      
      social_login_url(provider).should == root_url(subdomain: false) + "users/auth/" + provider
      social_login_url(provider2).should == root_url(subdomain: false) + "users/auth/" + provider2

    end
  end
end