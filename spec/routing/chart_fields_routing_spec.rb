require "rails_helper"

RSpec.describe ChartFieldsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/chart_fields").to route_to("chart_fields#index")
    end

    it "routes to #new" do
      expect(:get => "/chart_fields/new").to route_to("chart_fields#new")
    end

    it "routes to #show" do
      expect(:get => "/chart_fields/1").to route_to("chart_fields#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/chart_fields/1/edit").to route_to("chart_fields#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/chart_fields").to route_to("chart_fields#create")
    end

    it "routes to #update" do
      expect(:put => "/chart_fields/1").to route_to("chart_fields#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/chart_fields/1").to route_to("chart_fields#destroy", :id => "1")
    end

  end
end
