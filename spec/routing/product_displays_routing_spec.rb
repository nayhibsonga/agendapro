require "rails_helper"

RSpec.describe ProductDisplaysController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/product_displays").to route_to("product_displays#index")
    end

    it "routes to #new" do
      expect(:get => "/product_displays/new").to route_to("product_displays#new")
    end

    it "routes to #show" do
      expect(:get => "/product_displays/1").to route_to("product_displays#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/product_displays/1/edit").to route_to("product_displays#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/product_displays").to route_to("product_displays#create")
    end

    it "routes to #update" do
      expect(:put => "/product_displays/1").to route_to("product_displays#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/product_displays/1").to route_to("product_displays#destroy", :id => "1")
    end

  end
end
