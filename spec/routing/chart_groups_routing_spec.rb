require "rails_helper"

RSpec.describe ChartGroupsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/chart_groups").to route_to("chart_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/chart_groups/new").to route_to("chart_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/chart_groups/1").to route_to("chart_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/chart_groups/1/edit").to route_to("chart_groups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/chart_groups").to route_to("chart_groups#create")
    end

    it "routes to #update" do
      expect(:put => "/chart_groups/1").to route_to("chart_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/chart_groups/1").to route_to("chart_groups#destroy", :id => "1")
    end

  end
end
