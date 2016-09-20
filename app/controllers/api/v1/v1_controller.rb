module Api
	class V1::V1Controller < ApiController
		before_filter :check_api_key
		
		def check_api_key
			if request.headers['Token'] != 'ccac786f73f0fc017b7a62cb7f75df'
				return render json: {error: 'Not valid API Token.'}, status: 498
			end
		end
	end
end