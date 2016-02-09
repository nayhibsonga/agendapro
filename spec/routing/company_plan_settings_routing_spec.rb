require "rails_helper"

RSpec.describe CompanyPlanSettingsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/company_plan_settings").to route_to("company_plan_settings#index")
    end

    it "routes to #new" do
      expect(:get => "/company_plan_settings/new").to route_to("company_plan_settings#new")
    end

    it "routes to #show" do
      expect(:get => "/company_plan_settings/1").to route_to("company_plan_settings#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/company_plan_settings/1/edit").to route_to("company_plan_settings#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/company_plan_settings").to route_to("company_plan_settings#create")
    end

    it "routes to #update" do
      expect(:put => "/company_plan_settings/1").to route_to("company_plan_settings#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/company_plan_settings/1").to route_to("company_plan_settings#destroy", :id => "1")
    end

  end
end
