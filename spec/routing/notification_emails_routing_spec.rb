require "rails_helper"

RSpec.describe NotificationEmailsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/notification_emails").to route_to("notification_emails#index")
    end

    it "routes to #new" do
      expect(:get => "/notification_emails/new").to route_to("notification_emails#new")
    end

    it "routes to #show" do
      expect(:get => "/notification_emails/1").to route_to("notification_emails#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/notification_emails/1/edit").to route_to("notification_emails#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/notification_emails").to route_to("notification_emails#create")
    end

    it "routes to #update" do
      expect(:put => "/notification_emails/1").to route_to("notification_emails#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/notification_emails/1").to route_to("notification_emails#destroy", :id => "1")
    end

  end
end
