
if Rails.env.pagos?

	RestClient.log = 'log/rest_client.log'

	PuntoPagos::Config::PUNTOPAGOS_BASE_URL = {:production=>"https://www.puntopagos.com/", :sandbox=>"https://sandbox.puntopagos.com/", :local => "http://192.168.1.111:3000/"}

end