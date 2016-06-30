require 'rails_helper'

RSpec.describe "ChartGroups", :type => :request do
  describe "GET /chart_groups" do
    it "works! (now write some real specs)" do
      get chart_groups_path
      expect(response.status).to be(200)
    end
  end
end
