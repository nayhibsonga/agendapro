require "rails_helper"

RSpec.describe MarketplaceCategoriesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/marketplace_categories").to route_to("marketplace_categories#index")
    end

    it "routes to #new" do
      expect(:get => "/marketplace_categories/new").to route_to("marketplace_categories#new")
    end

    it "routes to #show" do
      expect(:get => "/marketplace_categories/1").to route_to("marketplace_categories#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/marketplace_categories/1/edit").to route_to("marketplace_categories#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/marketplace_categories").to route_to("marketplace_categories#create")
    end

    it "routes to #update" do
      expect(:put => "/marketplace_categories/1").to route_to("marketplace_categories#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/marketplace_categories/1").to route_to("marketplace_categories#destroy", :id => "1")
    end

  end
end
