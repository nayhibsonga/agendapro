class RegistrationsController < Devise::RegistrationsController
	layout "login"

  skip_before_filter :require_no_authentication, :only => [ :new, :create ]

  private

    def sign_up_params
      allow = [:first_name, :last_name, :phone, :email, :password, :password_confirmation, :role_id, company_attributes: [:name, :web_address, :plan_id, :logo, :payment_status_id, :economic_sector_id]]
      params.require(resource_name).permit(allow)
    end

end