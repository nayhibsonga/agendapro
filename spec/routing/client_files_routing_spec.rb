require "rails_helper"

RSpec.describe ClientFilesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/client_files").to route_to("client_files#index")
    end

    it "routes to #new" do
      expect(:get => "/client_files/new").to route_to("client_files#new")
    end

    it "routes to #show" do
      expect(:get => "/client_files/1").to route_to("client_files#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/client_files/1/edit").to route_to("client_files#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/client_files").to route_to("client_files#create")
    end

    it "routes to #update" do
      expect(:put => "/client_files/1").to route_to("client_files#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/client_files/1").to route_to("client_files#destroy", :id => "1")
    end

  end
end
