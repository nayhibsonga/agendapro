require 'rails_helper'

RSpec.describe "Surveys", :type => :request do
  describe "GET /surveys" do
    it "works! (now write some real specs)" do
      get surveys_path
      expect(response.status).to be(200)
    end
  end
end
