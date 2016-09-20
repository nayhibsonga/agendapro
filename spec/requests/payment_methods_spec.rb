require 'rails_helper'

RSpec.describe "PaymentMethods", :type => :request do
  describe "GET /payment_methods" do
    it "works! (now write some real specs)" do
      get payment_methods_path
      expect(response.status).to be(200)
    end
  end
end
