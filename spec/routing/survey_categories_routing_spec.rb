require "rails_helper"

RSpec.describe SurveyCategoriesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/survey_categories").to route_to("survey_categories#index")
    end

    it "routes to #new" do
      expect(:get => "/survey_categories/new").to route_to("survey_categories#new")
    end

    it "routes to #show" do
      expect(:get => "/survey_categories/1").to route_to("survey_categories#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/survey_categories/1/edit").to route_to("survey_categories#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/survey_categories").to route_to("survey_categories#create")
    end

    it "routes to #update" do
      expect(:put => "/survey_categories/1").to route_to("survey_categories#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/survey_categories/1").to route_to("survey_categories#destroy", :id => "1")
    end

  end
end
