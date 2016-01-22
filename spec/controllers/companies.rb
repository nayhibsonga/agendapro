require 'rails_helper'

describe CompaniesController do

	include UrlHelper
	login_super_admin
	#subject.current_user

	before(:each) do

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

	end

	let(:params) do
		{
			:id => @company.id,
			:amount => @new_plan.plan_countries.find_by(country_id: @company.country.id).price,
			:date => @date,
			:transaction_type_id => @transaction_type.id,
			:new_plan_id => @new_plan.id,
			:new_due => 0.0,
			:new_months => 1,
			:new_status_id => @new_payment_status.id
		}
	end


	#Super Admin
	it "should get companies for management" do

		get :manage

		expect(assigns(:companies)).to_not be nil
		expect(response).to render_template :manage

	end


	it "should correctly add a manual payment" do

		puts "Company: " + @company.id.to_s

		expect {post :add_payment, params}.to change(BillingRecord,:count).by(1)
		puts @new_payment_status.id.to_s
		expect(assigns(:company)).to_not be_nil
		expect(assigns(:company).plan_id).to eq(@new_plan.id)
		expect(assigns(:company).payment_status_id).to eq(@new_payment_status.id)
		expect(assigns(:company).due_amount).to eq(0)
		expect(assigns(:company).months_active_left).to eq(1)
		expect(response).to redirect_to(:action => "manage_company", :id => @company.id)

	end

	it "should deactivate a company" do

		post :deactivate_company, {:id => @company.id}

		expect(assigns(:company).active).to eq(false)
		expect(assigns(:company).months_active_left).to eq(0)
		expect(assigns(:company).payment_status_id).to eq(@payment_status_inactivo.id)

		expect(response).to redirect_to(:action => "manage_company", :id => @company.id)

	end


	context 'with_subdomain' do

		before(:each) do
			@request.host = "#{@company.web_address}.test.host"
		end

		############
		# OVERVIEW #
		############

		it "should redirect to root_path with wrong web_address " do

			wrong_address = @company.web_address + "wrong"

			@request.host = "#{wrong_address}.test.host"

			get :overview

			expect(response).to redirect_to(root_url(subdomain: false))

		end

		it "should redirect to root_path if not active workflow or search" do

			@request.host = "#{@company2}.test.host"
			get :overview

			expect(response).to redirect_to(root_url(subdomain: false))
			expect(flash[:alert]).to_not be_nil

		end

		it "should alert and render overview if location is set and doesn't exist" do

			get :overview, {:local => 12345}

			expect(assigns(:company)).to_not be nil

			expect(assigns(:locations)).to_not be_nil
			expect(assigns(:locations).empty?).to eq(false)

			expect(response).to render_template(:overview)

		end

		it "should get locations and render overview" do

			get :overview

			expect(assigns(:company)).to_not be nil

			expect(assigns(:locations)).to_not be_nil
			expect(assigns(:locations).empty?).to eq(false)

			expect(response).to render_template(:overview)

		end


		############
		# WORKFLOW #
		############

		it "(Workflow) should redirect to root_path with wrong web_address " do

			wrong_address = @company.web_address + "wrong"

			@request.host = "#{wrong_address}.test.host"

			get :workflow

			expect(response).to redirect_to(root_url(subdomain: false))

		end

		it "(Workflow) should redirect to root_path if not active workflow or search" do

			@request.host = "#{@company2}.test.host"
			get :workflow

			expect(response).to redirect_to(root_url(subdomain: false))
			expect(flash[:alert]).to_not be_nil

		end

		it "(Workflow) should alert and redirect to overview if location is set and doesn't exist" do

			get :workflow, {:local => 12345}

			expect(assigns(:company)).to_not be nil

			expect(response).to redirect_to(:controller => 'companies', :action => 'overview')

		end

		it "(Workflow) should render workflow" do

			get :overview

			expect(assigns(:company)).to_not be nil

			expect(response).to render_template(:workflow)

		end


	end


end
