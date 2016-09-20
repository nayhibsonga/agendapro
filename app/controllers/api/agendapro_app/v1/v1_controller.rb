module Api
  module AgendaproApp
	class V1::V1Controller < AgendaproAppController
		before_filter :check_api_key
		
		def check_api_key
			if request.headers['Token'] != '1jt3syunj8k8xn8am11q8yj4mh9az9'
				return render json: {error: 'Not valid API Token.'}, status: 498
			end
		end
	end
end
end