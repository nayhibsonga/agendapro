require 'rails_helper'

RSpec.describe "SurveyQuestionConstructs", :type => :request do
  describe "GET /survey_question_constructs" do
    it "works! (now write some real specs)" do
      get survey_question_constructs_path
      expect(response.status).to be(200)
    end
  end
end
