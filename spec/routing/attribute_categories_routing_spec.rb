require "rails_helper"

RSpec.describe AttributeCategoriesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/attribute_categories").to route_to("attribute_categories#index")
    end

    it "routes to #new" do
      expect(:get => "/attribute_categories/new").to route_to("attribute_categories#new")
    end

    it "routes to #show" do
      expect(:get => "/attribute_categories/1").to route_to("attribute_categories#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/attribute_categories/1/edit").to route_to("attribute_categories#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/attribute_categories").to route_to("attribute_categories#create")
    end

    it "routes to #update" do
      expect(:put => "/attribute_categories/1").to route_to("attribute_categories#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/attribute_categories/1").to route_to("attribute_categories#destroy", :id => "1")
    end

  end
end
