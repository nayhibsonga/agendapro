require 'rails_helper'

describe CompaniesController do

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

        @new_plan = @plan_premium
		@transaction_type = FactoryGirl.create(:transaction_type, :transaction_type_transferencia)
		@new_payment_status = @payment_status_activo
		@date = DateTime.now

	end

	let(:params) do
		{
			:id => @company.id, 
			:amount => @new_plan.price, 
			:date => @date, 
			:transaction_type_id => @transaction_type.id, 
			:new_plan_id => @new_plan.id, 
			:new_due => 0.0, 
			:new_months => 1, 
			:new_status_id => @new_payment_status.id
		}
	end		

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

	#Overview
	it "should redirect overview with location selected" do

		get :overview, :web_address => @company.web_address

	end

end