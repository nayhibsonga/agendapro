require 'rails_helper'

RSpec.describe "CompanyPlanSettings", :type => :request do
  describe "GET /company_plan_settings" do
    it "works! (now write some real specs)" do
      get company_plan_settings_path
      expect(response.status).to be(200)
    end
  end
end
