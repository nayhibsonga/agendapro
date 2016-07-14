class RegistrationsController < Devise::RegistrationsController

  skip_before_filter :require_no_authentication, :only => [ :new, :create ]

  before_filter :constraint_locale, only: [:new]

  private

    def sign_up_params
      allow = [:first_name, :last_name, :phone, :email, :password, :password_confirmation, :role_id, :receives_offers, company_attributes: [:name, :web_address, :plan_id, :logo, :payment_status_id, :country_id, :economic_sector_id, company_setting_attributes: [:before_booking, :after_booking]]]
      params.require(resource_name).permit(allow)
    end

    def account_update_params
    	allow = [:first_name, :last_name, :phone, :email, :password, :password_confirmation, :current_password, :role_id, :receives_offers, company_attributes: [:name, :web_address, :plan_id, :logo, :payment_status_id, :economic_sector_id]]
    	params.require(resource_name).permit(allow)
    end

end
