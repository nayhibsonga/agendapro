require 'rails_helper'
# spec/features/user_creates_a_foobar_spec.rb
feature 'User login' do

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
        @plan = FactoryGirl.create(:plan)
        @payment_status = FactoryGirl.create(:payment_status)
        @company = FactoryGirl.create(:company, plan: @plan, payment_status: @payment_status)
        @company_setting = FactoryGirl.create(:company_setting, company: @company, bank: @bank)

        #@role = FactoryGirl.build(:role)
        #@role.save
    	
  	end

    scenario 'User logins to dashboard as Registered User' do

        @user = FactoryGirl.build(:user, role: @role1) #, role_id: @role.id)
        @user.save
        login_as(@user, :scope => :user)

        visit '/dashboard'
        expect(page).to have_content 'Inicio'

        #within("#new_user") do
        #    fill_in 'user_email', :with => @user.email
        #    fill_in 'user_password', :with => 'password'
        #    click_button 'Ingresar'
        #    login_user
        #end

        #expect(page).to have_content 'Resumen'
        logout(:user)

    end

    scenario 'User logins to dashboard as Super Admin' do
        @user = FactoryGirl.build(:user, role: @role4) #, role_id: @role.id)
        @user.save
        login_as(@user, :scope => :user)

        visit '/dashboard'
        expect(page).to have_content 'Control de gestión'
        logout(:user)
    end

    scenario 'User logins to dashboard as Admin' do

        @user = FactoryGirl.build(:user, role: @role2, company: @company) #, role_id: @role.id)
        @user.save
        login_as(@user, :scope => :user)

        visit '/dashboard'
        expect(page).to have_content 'Resumen'
        expect(page).not_to have_content 'Control de gestión'
        logout(:user)
    end

end