class RegistrationsController < Devise::RegistrationsController

  private

    def sign_up_params
      allow = [:first_name, :last_name, :user_name, :phone, :email, :password, :password_confirmation, :role_id, company_attributes: [:name, :web_address, :plan_id, :logo, :payment_status_id, :economic_sector_id]]
      params.require(resource_name).permit(allow)
    end

end