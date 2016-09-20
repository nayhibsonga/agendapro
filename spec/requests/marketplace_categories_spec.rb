require 'rails_helper'

RSpec.describe "MarketplaceCategories", :type => :request do
  describe "GET /marketplace_categories" do
    it "works! (now write some real specs)" do
      get marketplace_categories_path
      expect(response.status).to be(200)
    end
  end
end
