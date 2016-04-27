Agendapro::Application.configure do
  # Se setea el host por defecto en development
  Rails.application.routes.default_url_options[:host] = 'lvh.me:3000'

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.action_mailer.default_url_options = { :host => 'lvh.me:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.smtp_settings = {
    :address   => "smtp.sparkpostmail.com",
    :port      => 587, # 25, 465 or 587
    :enable_starttls_auto => true, # detects and uses STARTTLS
    :user_name => "SMTP_Injection",
    :password  => "ba9959858c917439ef4403556427a811703be9f8", # SMTP password is any valid API key
    :authentication => :login, # Mandrill supports 'plain' or 'login'
    :domain => 'agendapro.co', # your domain to identify your server when connecting
  }

end
