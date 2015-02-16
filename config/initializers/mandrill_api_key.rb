if Rails.env.development?
  Agendapro::Application.config.api_key = ENV["MANDRILL_API_KEY_DEV"]
end

if Rails.env.production?
  Agendapro::Application.config.api_key = ENV["MANDRILL_API_KEY_PROD"]
end
