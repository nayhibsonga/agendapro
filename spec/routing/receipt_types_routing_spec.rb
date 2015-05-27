require "rails_helper"

RSpec.describe ReceiptTypesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/receipt_types").to route_to("receipt_types#index")
    end

    it "routes to #new" do
      expect(:get => "/receipt_types/new").to route_to("receipt_types#new")
    end

    it "routes to #show" do
      expect(:get => "/receipt_types/1").to route_to("receipt_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/receipt_types/1/edit").to route_to("receipt_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/receipt_types").to route_to("receipt_types#create")
    end

    it "routes to #update" do
      expect(:put => "/receipt_types/1").to route_to("receipt_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/receipt_types/1").to route_to("receipt_types#destroy", :id => "1")
    end

  end
end
