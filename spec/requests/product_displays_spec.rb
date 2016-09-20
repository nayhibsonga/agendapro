require 'rails_helper'

RSpec.describe "ProductDisplays", :type => :request do
  describe "GET /product_displays" do
    it "works! (now write some real specs)" do
      get product_displays_path
      expect(response.status).to be(200)
    end
  end
end
