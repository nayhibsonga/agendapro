require 'rails_helper'

describe SearchsController do

	#login_user
	before(:each) do
		
		@role1 = FactoryGirl.create(:role)
        @role2 = FactoryGirl.create(:role, :admin_role)
        @role3 = FactoryGirl.create(:role, :general_admin_role)
        @role4 = FactoryGirl.create(:role, :super_admin_role)
        @role5 = FactoryGirl.create(:role, :staff_role)
        @role6 = FactoryGirl.create(:role, :unregistered_role)
        @role7 = FactoryGirl.create(:role, :recepcionista_role)
        @role8 = FactoryGirl.create(:role, :staff_uneditable_role)

        @country = FactoryGirl.create(:country)
        @region = FactoryGirl.create(:region, country: @country)
        @city = FactoryGirl.create(:city, region: @region)
        @district = FactoryGirl.create(:district, city: @city)

        @bank = FactoryGirl.create(:bank)
        @plan = FactoryGirl.create(:plan, locations: 5, service_providers: 5)
        @payment_status = FactoryGirl.create(:payment_status)
        @company = FactoryGirl.create(:company, plan: @plan, payment_status: @payment_status)
        @company_setting = FactoryGirl.create(:company_setting, company: @company, bank: @bank)
        
        @location1 = FactoryGirl.create(:location, district: @district, company: @company)
        @location2 = FactoryGirl.create(:location, district: @district, company: @company, active: false)

        @service_category1 = FactoryGirl.create(:service_category, company: @company)
        @service1 = FactoryGirl.create(:service, name: "Hola", company: @company, service_category: @service_category1)

        @service_category2 = FactoryGirl.create(:service_category, company: @company)
        @service2 = FactoryGirl.create(:service, name: "Chao", company: @company, service_category: @service_category2)

        @service_provider1 = FactoryGirl.create(:service_provider, location: @location1, company: @company)
        @service_provider2 = FactoryGirl.create(:service_provider, location: @location2, company: @company)

        @service_staff1 = FactoryGirl.create(:service_staff, service: @service1, service_provider: @service_provider1)
        @service_staff2 = FactoryGirl.create(:service_staff, service: @service2, service_provider: @service_provider2)

	end

	it "should redirect with missing params" do
		get :search
		expect(response).to redirect_to(root_path)
	end

	it "should find company with name" do
		get :search, :inputSearch => @company.name, :latitude => @location1.latitude, :longitude => @location1.longitude, :inputLocalization => @location1.address
		assigns(:results).should_not be_nil
		expect(assigns(:results).empty?).to eq(false)
		response.should render_template :search
		expect(response).to render_template :search
	end

	it "should not find inactive locations" do
		get :search, :inputSearch => @service2.name, :latitude => @location1.latitude, :longitude => @location1.longitude, :inputLocalization => @location1.address
		assigns(:results).should_not be_nil
		expect(assigns(:results).empty?).to eq(true)
		response.should render_template :search
		expect(response).to render_template :search
	end

end