module Api
  module Horachic
	class V1::V1Controller < HorachicController
		before_filter :check_api_key
		
		def check_api_key
			if request.headers['Token'] != '5ef724454a1a642b369fe92ef1700c37'
				return render json: {error: 'Not valid API Token.'}, status: 498
			end
		end
	end
end
end