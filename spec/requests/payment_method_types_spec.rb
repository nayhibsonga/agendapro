require 'rails_helper'

RSpec.describe "PaymentMethodTypes", :type => :request do
  describe "GET /payment_method_types" do
    it "works! (now write some real specs)" do
      get payment_method_types_path
      expect(response.status).to be(200)
    end
  end
end
