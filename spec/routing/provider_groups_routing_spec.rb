require "rails_helper"

RSpec.describe ProviderGroupsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/provider_groups").to route_to("provider_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/provider_groups/new").to route_to("provider_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/provider_groups/1").to route_to("provider_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/provider_groups/1/edit").to route_to("provider_groups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/provider_groups").to route_to("provider_groups#create")
    end

    it "routes to #update" do
      expect(:put => "/provider_groups/1").to route_to("provider_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/provider_groups/1").to route_to("provider_groups#destroy", :id => "1")
    end

  end
end
