require 'rails_helper'

RSpec.describe EmailContentController, :type => :controller do

  describe "GET upload" do
    it "returns http success" do
      get :upload
      expect(response).to be_success
    end
  end

end
