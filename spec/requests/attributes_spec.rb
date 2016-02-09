require 'rails_helper'

RSpec.describe "Attributes", :type => :request do
  describe "GET /attributes" do
    it "works! (now write some real specs)" do
      get attributes_path
      expect(response.status).to be(200)
    end
  end
end
