require "rails_helper"

RSpec.describe CashiersController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/cashiers").to route_to("cashiers#index")
    end

    it "routes to #new" do
      expect(:get => "/cashiers/new").to route_to("cashiers#new")
    end

    it "routes to #show" do
      expect(:get => "/cashiers/1").to route_to("cashiers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/cashiers/1/edit").to route_to("cashiers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/cashiers").to route_to("cashiers#create")
    end

    it "routes to #update" do
      expect(:put => "/cashiers/1").to route_to("cashiers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/cashiers/1").to route_to("cashiers#destroy", :id => "1")
    end

  end
end
