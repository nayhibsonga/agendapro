require 'rails_helper'

RSpec.describe "CompanyPaymentMethods", :type => :request do
  describe "GET /company_payment_methods" do
    it "works! (now write some real specs)" do
      get company_payment_methods_path
      expect(response.status).to be(200)
    end
  end
end
