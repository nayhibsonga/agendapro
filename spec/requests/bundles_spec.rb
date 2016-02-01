require 'rails_helper'

RSpec.describe "Bundles", :type => :request do
  describe "GET /bundles" do
    it "works! (now write some real specs)" do
      get bundles_path
      expect(response.status).to be(200)
    end
  end
end
