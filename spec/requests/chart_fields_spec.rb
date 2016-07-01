require 'rails_helper'

RSpec.describe "ChartFields", :type => :request do
  describe "GET /chart_fields" do
    it "works! (now write some real specs)" do
      get chart_fields_path
      expect(response.status).to be(200)
    end
  end
end
