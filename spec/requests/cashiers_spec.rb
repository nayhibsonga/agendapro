require 'rails_helper'

RSpec.describe "Cashiers", :type => :request do
  describe "GET /cashiers" do
    it "works! (now write some real specs)" do
      get cashiers_path
      expect(response.status).to be(200)
    end
  end
end
