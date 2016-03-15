module Api
  module CustomApp
	class V1::V1Controller < CustomAppController
		before_filter :check_api_key
		
		def check_api_key
			if request.headers['Token'] != 'svnxl64pjeio71w3e3st0y31rx3i6i'
				return render json: {error: 'Not valid API Token.'}, status: 498
			end
		end
	end
end
end