require "rails_helper"

RSpec.describe SurveyConstructsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/survey_constructs").to route_to("survey_constructs#index")
    end

    it "routes to #new" do
      expect(:get => "/survey_constructs/new").to route_to("survey_constructs#new")
    end

    it "routes to #show" do
      expect(:get => "/survey_constructs/1").to route_to("survey_constructs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/survey_constructs/1/edit").to route_to("survey_constructs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/survey_constructs").to route_to("survey_constructs#create")
    end

    it "routes to #update" do
      expect(:put => "/survey_constructs/1").to route_to("survey_constructs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/survey_constructs/1").to route_to("survey_constructs#destroy", :id => "1")
    end

  end
end
