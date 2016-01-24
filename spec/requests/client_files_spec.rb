require 'rails_helper'

RSpec.describe "ClientFiles", :type => :request do
  describe "GET /client_files" do
    it "works! (now write some real specs)" do
      get client_files_path
      expect(response.status).to be(200)
    end
  end
end
