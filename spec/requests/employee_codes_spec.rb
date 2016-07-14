require 'rails_helper'

RSpec.describe "EmployeeCodes", :type => :request do
  describe "GET /employee_codes" do
    it "works! (now write some real specs)" do
      get employee_codes_path
      expect(response.status).to be(200)
    end
  end
end
