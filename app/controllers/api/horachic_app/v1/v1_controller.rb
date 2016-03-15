module Api
  module HorachicApp
	class V1::V1Controller < HorachicAppController
		before_filter :check_api_key
		
		def check_api_key
			if request.headers['Token'] != '5r1t5yldv4efktg8bkkm7vvmhqmw30'
				return render json: {error: 'Not valid API Token.'}, status: 498
			end
		end
	end
end
end