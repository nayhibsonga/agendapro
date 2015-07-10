require 'rails_helper'

RSpec.describe "ReceiptTypes", :type => :request do
  describe "GET /receipt_types" do
    it "works! (now write some real specs)" do
      get receipt_types_path
      expect(response.status).to be(200)
    end
  end
end
