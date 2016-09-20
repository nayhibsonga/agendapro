require "rails_helper"

RSpec.describe PaymentMethodTypesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/payment_method_types").to route_to("payment_method_types#index")
    end

    it "routes to #new" do
      expect(:get => "/payment_method_types/new").to route_to("payment_method_types#new")
    end

    it "routes to #show" do
      expect(:get => "/payment_method_types/1").to route_to("payment_method_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/payment_method_types/1/edit").to route_to("payment_method_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/payment_method_types").to route_to("payment_method_types#create")
    end

    it "routes to #update" do
      expect(:put => "/payment_method_types/1").to route_to("payment_method_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/payment_method_types/1").to route_to("payment_method_types#destroy", :id => "1")
    end

  end
end
