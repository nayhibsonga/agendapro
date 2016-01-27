require 'rails_helper'

RSpec.describe "CustomFilters", :type => :request do
  describe "GET /custom_filters" do
    it "works! (now write some real specs)" do
      get custom_filters_path
      expect(response.status).to be(200)
    end
  end
end
