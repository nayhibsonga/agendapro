require 'rails_helper'

RSpec.describe "SurveyQuestions", :type => :request do
  describe "GET /survey_questions" do
    it "works! (now write some real specs)" do
      get survey_questions_path
      expect(response.status).to be(200)
    end
  end
end
