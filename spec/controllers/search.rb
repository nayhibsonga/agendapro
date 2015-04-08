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
        @district_las_condes = FactoryGirl.create(:district, name: "Las Condes", city: @city)
        @district_providencia = FactoryGirl.create(:district, name: "Providencia", city: @city)

        @bank = FactoryGirl.create(:bank)
        @plan = FactoryGirl.create(:plan, locations: 5, service_providers: 5)
        @payment_status = FactoryGirl.create(:payment_status)
        @company = FactoryGirl.create(:company, plan: @plan, payment_status: @payment_status)
        @company_setting = FactoryGirl.create(:company_setting, company: @company, bank: @bank)

        
        #Active location (Elisa Cole 48)
        @location1 = FactoryGirl.create(:location, name: "Local Elisa", district: @district, company: @company)
        #Inactive location (Ntra Sra de ...)
        @location2 = FactoryGirl.create(:location, name: "Local Ntra Sra", district: @district_las_condes, company: @company, active: false, latitude: -33.4128002, longitude: -70.5917578, address: "Nuestra Señora de los Ángeles 185")
        @location3 = FactoryGirl.create(:location, name: "Local Elisa 2", district: @district, company: @company, address: "Elisa Cole 15", online_booking: false)

        @service_category1 = FactoryGirl.create(:service_category, name: "Categoría 1", company: @company)
        @service1 = FactoryGirl.create(:service, name: "Hola", company: @company, service_category: @service_category1)
        @service_provider1 = FactoryGirl.create(:service_provider, location: @location1, company: @company)
        @service_staff1 = FactoryGirl.create(:service_staff, service: @service1, service_provider: @service_provider1)

        @service_category2 = FactoryGirl.create(:service_category, name: "Categoría 2", company: @company)
        @service2 = FactoryGirl.create(:service, name: "Chao", company: @company, service_category: @service_category2)  
        @service_provider2 = FactoryGirl.create(:service_provider, location: @location2, company: @company)
        @service_staff2 = FactoryGirl.create(:service_staff, service: @service2, service_provider: @service_provider2)

        #Service with online_booking = false
        @service3 = FactoryGirl.create(:service, name: "notonlinebookable", company: @company, service_category: @service_category1, online_booking: false)
        @service_staff3 = FactoryGirl.create(:service_staff, service: @service3, service_provider: @service_provider1)

        @service4 = FactoryGirl.create(:service, name: "inactiveservice", company: @company, service_category: @service_category1, online_booking: false, active: false)
        @service_staff4 = FactoryGirl.create(:service_staff, service: @service4, service_provider: @service_provider1)

        @service_category5 = FactoryGirl.create(:service_category, name: "Categoría 4", company: @company)
        @service5 = FactoryGirl.create(:service, name: "Bonjour", company: @company, service_category: @service_category5)  
        @service_provider5 = FactoryGirl.create(:service_provider, location: @location3, company: @company)
        @service_staff5 = FactoryGirl.create(:service_staff, service: @service5, service_provider: @service_provider5)



        #Not searchable company
        @company2 = FactoryGirl.create(:company, name: "notsearchablecompany", web_address: "company2", plan: @plan, payment_status: @payment_status)
        @company_setting2 = FactoryGirl.create(:company_setting, company: @company2, bank: @bank, activate_search: false, activate_workflow: false)

        @location_company2 = FactoryGirl.create(:location, name: "Local Providencia", district: @district_providencia, company: @company2, active: true, latitude: -33.4235516, longitude: -70.61243159999998, address: "Providencia 200")
        @service_category_company2 = FactoryGirl.create(:service_category, name: "Categoría 3", company: @company2)
        @service_provider_company2 = FactoryGirl.create(:service_provider, location: @location_company2, company: @company2)
        @service_company2 = FactoryGirl.create(:service, name: "notactivesearchworkflowservice", company: @company2, service_category: @service_category_company2, online_booking: true)
        @service_staff_company2 = FactoryGirl.create(:service_staff, service: @service_company2, service_provider: @service_provider_company2)



	end

	it "should redirect with missing params" do
		get :search
		expect(response).to redirect_to(root_path)
	end

	it "should find company with name" do
		get :search, :inputSearch => @company.name, :latitude => @location1.latitude, :longitude => @location1.longitude, :inputLocalization => @location1.address
		assigns(:results).should_not be_nil
		expect(assigns(:results).empty?).to eq(false)
		#response.should render_template :search
		expect(response).to render_template :search
	end

    it "should find unowned company without services" do

    end

    it "should not find companies without activate workflow and search" do
            get :search, :inputSearch => @service_company2.name, :latitude => @location_company2.latitude, :longitude => @location_company2.longitude, :inputLocalization => @location_company2.address
            puts "Searching: " + @service_company2.name
            assigns(:results).should_not be_nil
            puts assigns(:results).inspect
            expect(assigns(:results).empty?).to eq(true)
            expect(response).to render_template :search
    end

	it "should not find inactive locations" do
		get :search, :inputSearch => @service2.name, :latitude => @location1.latitude, :longitude => @location1.longitude, :inputLocalization => @location1.address
		assigns(:results).should_not be_nil
		expect(assigns(:results).empty?).to eq(true)
		#response.should render_template :search
		expect(response).to render_template :search
	end

    it "should not find locations without online_booking" do
        get :search, :inputSearch => @service5.name, :latitude => @location3.latitude, :longitude => @location3.longitude, :inputLocalization => @location3.address
        puts "Searching: " + @service5.name
        assigns(:results).should_not be_nil
        puts assigns(:results).inspect
        expect(assigns(:results).empty?).to eq(true)
        #response.should render_template :search
        expect(response).to render_template :search
    end

    it "should not find services without online_booking" do
            get :search, :inputSearch => @service3.name, :latitude => @location1.latitude, :longitude => @location1.longitude, :inputLocalization => @location1.address
            puts "Searching: " + @service3.name
            assigns(:results).should_not be_nil
            puts assigns(:results).inspect
            expect(assigns(:results).empty?).to eq(true)
            expect(response).to render_template :search
    end

    it "should not find inactive services" do
            get :search, :inputSearch => @service4.name, :latitude => @location1.latitude, :longitude => @location1.longitude, :inputLocalization => @location1.address
            puts "Searching: " + @service4.name
            assigns(:results).should_not be_nil
            puts assigns(:results).inspect
            expect(assigns(:results).empty?).to eq(true)
            expect(response).to render_template :search
    end

end