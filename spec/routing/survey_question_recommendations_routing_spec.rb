require "rails_helper"

RSpec.describe SurveyQuestionRecommendationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/survey_question_recommendations").to route_to("survey_question_recommendations#index")
    end

    it "routes to #new" do
      expect(:get => "/survey_question_recommendations/new").to route_to("survey_question_recommendations#new")
    end

    it "routes to #show" do
      expect(:get => "/survey_question_recommendations/1").to route_to("survey_question_recommendations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/survey_question_recommendations/1/edit").to route_to("survey_question_recommendations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/survey_question_recommendations").to route_to("survey_question_recommendations#create")
    end

    it "routes to #update" do
      expect(:put => "/survey_question_recommendations/1").to route_to("survey_question_recommendations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/survey_question_recommendations/1").to route_to("survey_question_recommendations#destroy", :id => "1")
    end

  end
end
