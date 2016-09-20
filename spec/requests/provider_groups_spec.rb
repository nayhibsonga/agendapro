require 'rails_helper'

RSpec.describe "ProviderGroups", :type => :request do
  describe "GET /provider_groups" do
    it "works! (now write some real specs)" do
      get provider_groups_path
      expect(response.status).to be(200)
    end
  end
end
