require "rails_helper"

RSpec.describe AttributeGroupsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/attribute_groups").to route_to("attribute_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/attribute_groups/new").to route_to("attribute_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/attribute_groups/1").to route_to("attribute_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/attribute_groups/1/edit").to route_to("attribute_groups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/attribute_groups").to route_to("attribute_groups#create")
    end

    it "routes to #update" do
      expect(:put => "/attribute_groups/1").to route_to("attribute_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/attribute_groups/1").to route_to("attribute_groups#destroy", :id => "1")
    end

  end
end
