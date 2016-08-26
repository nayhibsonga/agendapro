require "rails_helper"

RSpec.describe SurveyAttributesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/survey_attributes").to route_to("survey_attributes#index")
    end

    it "routes to #new" do
      expect(:get => "/survey_attributes/new").to route_to("survey_attributes#new")
    end

    it "routes to #show" do
      expect(:get => "/survey_attributes/1").to route_to("survey_attributes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/survey_attributes/1/edit").to route_to("survey_attributes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/survey_attributes").to route_to("survey_attributes#create")
    end

    it "routes to #update" do
      expect(:put => "/survey_attributes/1").to route_to("survey_attributes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/survey_attributes/1").to route_to("survey_attributes#destroy", :id => "1")
    end

  end
end
