require 'rails_helper'

RSpec.describe "SurveyCategories", :type => :request do
  describe "GET /survey_categories" do
    it "works! (now write some real specs)" do
      get survey_categories_path
      expect(response.status).to be(200)
    end
  end
end
