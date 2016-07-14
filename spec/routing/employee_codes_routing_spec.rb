require "rails_helper"

RSpec.describe EmployeeCodesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/employee_codes").to route_to("employee_codes#index")
    end

    it "routes to #new" do
      expect(:get => "/employee_codes/new").to route_to("employee_codes#new")
    end

    it "routes to #show" do
      expect(:get => "/employee_codes/1").to route_to("employee_codes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/employee_codes/1/edit").to route_to("employee_codes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/employee_codes").to route_to("employee_codes#create")
    end

    it "routes to #update" do
      expect(:put => "/employee_codes/1").to route_to("employee_codes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/employee_codes/1").to route_to("employee_codes#destroy", :id => "1")
    end

  end
end
