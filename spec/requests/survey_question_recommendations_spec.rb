require 'rails_helper'

RSpec.describe "SurveyQuestionRecommendations", :type => :request do
  describe "GET /survey_question_recommendations" do
    it "works! (now write some real specs)" do
      get survey_question_recommendations_path
      expect(response.status).to be(200)
    end
  end
end
