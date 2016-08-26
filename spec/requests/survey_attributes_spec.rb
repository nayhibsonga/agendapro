require 'rails_helper'

RSpec.describe "SurveyAttributes", :type => :request do
  describe "GET /survey_attributes" do
    it "works! (now write some real specs)" do
      get survey_attributes_path
      expect(response.status).to be(200)
    end
  end
end
