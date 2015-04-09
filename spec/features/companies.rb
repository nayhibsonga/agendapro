require 'rails_helper'
# spec/features/user_creates_a_foobar_spec.rb
feature 'Companies' do

    include UrlHelper

	background do

        @role1 = FactoryGirl.create(:role)
        @role2 = FactoryGirl.create(:role, :admin_role)
        @role3 = FactoryGirl.create(:role, :general_admin_role)
        @role4 = FactoryGirl.create(:role, :super_admin_role)
        @role5 = FactoryGirl.create(:role, :staff_role)
        @role6 = FactoryGirl.create(:role, :unregistered_role)
        @role7 = FactoryGirl.create(:role, :recepcionista_role)
        @role8 = FactoryGirl.create(:role, :staff_uneditable_role)

        @plan_personal = FactoryGirl.create(:plan)
        @plan_basico = FactoryGirl.create(:plan, :plan_basico)
        @plan_beta = FactoryGirl.create(:plan, :plan_beta)
        @plan_premium = FactoryGirl.create(:plan, :plan_premium)
        @plan_trial = FactoryGirl.create(:plan, :plan_trial)
        @plan_normal = FactoryGirl.create(:plan, :plan_normal)

        @day_lunes = FactoryGirl.create(:day, name: "Lunes")
        @day_martes = FactoryGirl.create(:day, name: "Martes")
        @day_miercoles = FactoryGirl.create(:day, name: "Miércoles")
        @day_jueves = FactoryGirl.create(:day, name: "Jueves")
        @day_viernes = FactoryGirl.create(:day, name: "Viernes")
        @day_sabado = FactoryGirl.create(:day, name: "Sábado")
        @day_domingo = FactoryGirl.create(:day, name: "Domingo")

        @payment_status_activo = FactoryGirl.create(:payment_status)
        @payment_status_vencido = FactoryGirl.create(:payment_status, :vencido)
        @payment_status_trial = FactoryGirl.create(:payment_status, :trial)
        @payment_status_bloqueado = FactoryGirl.create(:payment_status, :bloqueado)
        @payment_status_emitido = FactoryGirl.create(:payment_status, :emitido)
        @payment_status_inactivo = FactoryGirl.create(:payment_status, :inactivo)
        @payment_status_admin = FactoryGirl.create(:payment_status, :admin)

        @country = FactoryGirl.create(:country)
        @region = FactoryGirl.create(:region, country: @country)
        @city = FactoryGirl.create(:city, region: @region)
        @district = FactoryGirl.create(:district, city: @city)
        @district_las_condes = FactoryGirl.create(:district, name: "Las Condes", city: @city)
        @district_providencia = FactoryGirl.create(:district, name: "Providencia", city: @city)

        @bank = FactoryGirl.create(:bank)

        @company = FactoryGirl.create(:company, plan: @plan_trial, payment_status: @payment_status_trial)
        @company_setting = FactoryGirl.create(:company_setting, company: @company, bank: @bank)
        @online_cancelation_policy = FactoryGirl.create(:online_cancelation_policy, company_setting: @company_setting)

        @location = FactoryGirl.create(:location, district: @district, company: @company)

        @location_time1 = FactoryGirl.create(:location_time, location: @location, day: @day_lunes)
        @location_time2 = FactoryGirl.create(:location_time, location: @location, day: @day_martes)
        @location_time3 = FactoryGirl.create(:location_time, location: @location, day: @day_miercoles)
        @location_time4 = FactoryGirl.create(:location_time, location: @location, day: @day_jueves)
        @location_time5 = FactoryGirl.create(:location_time, location: @location, day: @day_viernes)

        @service_category1 = FactoryGirl.create(:service_category, name: "Categoría 1", company: @company)
        @service1 = FactoryGirl.create(:service, name: "Hola", company: @company, service_category: @service_category1)
        @service_provider1 = FactoryGirl.create(:service_provider, location: @location, company: @company)
        @service_staff1 = FactoryGirl.create(:service_staff, service: @service1, service_provider: @service_provider1)

        @provider_time1 = FactoryGirl.create(:provider_time, service_provider: @service_provider1, day: @day_lunes)
        @provider_time2 = FactoryGirl.create(:provider_time, service_provider: @service_provider1, day: @day_martes)
        @provider_time3 = FactoryGirl.create(:provider_time, service_provider: @service_provider1, day: @day_miercoles)
        @provider_time4 = FactoryGirl.create(:provider_time, service_provider: @service_provider1, day: @day_jueves)
        @provider_time5 = FactoryGirl.create(:provider_time, service_provider: @service_provider1, day: @day_viernes)

        @company2 = FactoryGirl.create(:company, name: "notsearchablecompany", web_address: "company2", plan: @plan_trial, payment_status: @payment_status_trial)
        @company_setting2 = FactoryGirl.create(:company_setting, company: @company2, bank: @bank, activate_search: false, activate_workflow: false)

        @new_plan = @plan_premium
        @transaction_type = FactoryGirl.create(:transaction_type, :transaction_type_transferencia)
        @new_payment_status = @payment_status_activo
        @date = DateTime.now

        Capybara.app_host = "http://#{@company.web_address}.lvh.me:3000"
    	
  	end

    scenario 'Fills user data when logged', :js => true do

        @user = FactoryGirl.build(:user, role: @role1) #, role_id: @role.id)
        @user.save
        login_as(@user, :scope => :user)

        visit Capybara.app_host

        expect(page).to have_content "Selecciona el lugar"

        loc_radio = 'localOption' + @location.id.to_s
        choose loc_radio
        click_link 'boton-agendar'

        expect(page).to have_content "Seleccione un servicio"

        choose 'serviceRadio'
        
        find(".next2").click

        #find(".hora-disponible").click

        #find(".next2").click

        page.should have_field('firstName', with: @user.first_name)
        page.should have_field('lastName', with: @user.last_name)
        page.should have_field('email', with: @user.email)
        page.should have_field('phone', with: @user.phone)

    end

    scenario 'Uses the optimizer', :js => true do

        visit Capybara.app_host
        loc_radio = 'localOption' + @location.id.to_s
        choose loc_radio
        click_link 'boton-agendar'

        click_button 'optimizerOpenBtn'

    end

end