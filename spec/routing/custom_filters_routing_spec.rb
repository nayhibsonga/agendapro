require "rails_helper"

RSpec.describe CustomFiltersController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/custom_filters").to route_to("custom_filters#index")
    end

    it "routes to #new" do
      expect(:get => "/custom_filters/new").to route_to("custom_filters#new")
    end

    it "routes to #show" do
      expect(:get => "/custom_filters/1").to route_to("custom_filters#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/custom_filters/1/edit").to route_to("custom_filters#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/custom_filters").to route_to("custom_filters#create")
    end

    it "routes to #update" do
      expect(:put => "/custom_filters/1").to route_to("custom_filters#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/custom_filters/1").to route_to("custom_filters#destroy", :id => "1")
    end

  end
end
