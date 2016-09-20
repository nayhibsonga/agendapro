require "rails_helper"

RSpec.describe CompanyFilesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/company_files").to route_to("company_files#index")
    end

    it "routes to #new" do
      expect(:get => "/company_files/new").to route_to("company_files#new")
    end

    it "routes to #show" do
      expect(:get => "/company_files/1").to route_to("company_files#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/company_files/1/edit").to route_to("company_files#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/company_files").to route_to("company_files#create")
    end

    it "routes to #update" do
      expect(:put => "/company_files/1").to route_to("company_files#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/company_files/1").to route_to("company_files#destroy", :id => "1")
    end

  end
end
