module Api
	class V2::V2Controller < ApiController
		before_filter :check_api_key
		
		def check_api_key
			if request.headers['Token'] != '5ef724454a1a642b369fe92ef1700c37'
				return render json: {error: 'Not valid API Token.'}, status: 498
			end
		end
	end
end