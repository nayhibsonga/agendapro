module Api
  class CustomApp::CustomAppController < ApiController
    before_filter :check_auth_token

    def check_auth_token
      if !request.headers['Company-Token'].present?
        return render json: {error: 'No company. Token not present.'}, status: 403
      else
        @api_company = Company.api_decode_and_find(request.headers['Company-Token'])
        if !@api_company.present?
          return render json: {error: 'Not authenticated. Invalid Company Token'}, status: 403
        end
      end
    end
  end
end