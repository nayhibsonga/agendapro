require 'rails_helper'

RSpec.describe "AttributeGroups", :type => :request do
  describe "GET /attribute_groups" do
    it "works! (now write some real specs)" do
      get attribute_groups_path
      expect(response.status).to be(200)
    end
  end
end
