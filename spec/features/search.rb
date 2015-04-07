require 'rails_helper'
# spec/features/user_creates_a_foobar_spec.rb
feature 'Search' do

	background do

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

    scenario 'Finds company by name' do

        visit root_path

        fill_in 'inputLocalization', :with => @location1.address
        fill_in 'inputSearch', :with => @company_name
        click_button 'search_btn'

        #get :search, :inputSearch => @company.name, :latitude => @location1.latitude, :longitude => @location1.longitude, :inputLocalization => @location1.address

        expect(page).to have_content "Estos son los resultados"
        #expect(page).not_to have_content "Lo sentimos, no hemos encontrado resultados para tu búsqueda."

    end

    scenario 'Results are empty with location not active' do
        
        visit root_path

        fill_in 'inputLocalization', :with => @location1.address
        fill_in 'inputSearch', :with => @service2.name
        click_button 'search_btn'

        expect(page).to have_content "Lo sentimos, no hemos encontrado resultados para tu búsqueda."

    end

end