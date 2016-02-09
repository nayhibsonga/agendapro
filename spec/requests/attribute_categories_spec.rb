require 'rails_helper'

RSpec.describe "AttributeCategories", :type => :request do
  describe "GET /attribute_categories" do
    it "works! (now write some real specs)" do
      get attribute_categories_path
      expect(response.status).to be(200)
    end
  end
end
