require "rails_helper"

RSpec.describe PaymentMethodsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/payment_methods").to route_to("payment_methods#index")
    end

    it "routes to #new" do
      expect(:get => "/payment_methods/new").to route_to("payment_methods#new")
    end

    it "routes to #show" do
      expect(:get => "/payment_methods/1").to route_to("payment_methods#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/payment_methods/1/edit").to route_to("payment_methods#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/payment_methods").to route_to("payment_methods#create")
    end

    it "routes to #update" do
      expect(:put => "/payment_methods/1").to route_to("payment_methods#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/payment_methods/1").to route_to("payment_methods#destroy", :id => "1")
    end

  end
end
