require File.expand_path('../boot', __FILE__)

require 'csv'

require 'rails/all'



# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Agendapro
  class Application < Rails::Application

    config.assets.enabled = true

    config.assets.precompile << Proc.new { |path|
      if path =~ /\.(css|js|gif|png|jpg|otf|eot|svg|ttf|woff)\z/
        full_path = Rails.application.assets.resolve(path).to_path
        asset_paths = %w( app/assets vendor/assets lib/assets)
        if ((asset_paths.any? {|ap| full_path.include? ap}) && !path.starts_with?('_'))
          puts "\tIncluding: " + full_path
          true
        else
          puts "\tExcluding: " + full_path
          false
        end
      else
        false
      end
    }

    # config.encoding = "utf-8"

    # config.assets.precompile += %w( ckeditor/* )

    config.before_configuration do
      env_file = "#{Rails.root}/config/local_env.yml"
      YAML.load_file(env_file).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
      
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Santiago'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.fallbacks = true
    config.i18n.load_path += Dir[Rails.root.join('config','locales', '*.{rb,yml}').to_s]
    config.i18n.fallbacks = {"es_CL" => "es"}
    config.i18n.default_locale = :"es"
  end
end
