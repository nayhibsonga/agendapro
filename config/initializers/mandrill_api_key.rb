if Rails.env.development?
  Agendapro::Application.config.api_key = 'UhM-Y7RNxHZJeJa4ajil6Q'
end

if Rails.env.production?
  Agendapro::Application.config.api_key = ENV["MANDRILL_API_KEY_PROD"]
  Excon.defaults[:write_timeout] = 600
end

if Rails.env.test?
	Agendapro::Application.config.api_key = '_tV8tq0_hG-JW7_MTjZb-A'
end

if Rails.env.pagos?
  Agendapro::Application.config.api_key = 'UhM-Y7RNxHZJeJa4ajil6Q'
end
