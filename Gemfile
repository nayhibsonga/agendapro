source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.1'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
#gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
#gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem "therubyracer"

# Comentado dado que no debería ser usado...
# gem "less-rails", '2.3.3'
# gem "twitter-bootstrap-rails"
# gem "font-awesome-rails"

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

gem 'cocoon'

gem 'whenever', :require => false

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :development, :pagos do
  #mejores errores
  gem 'better_errors'
  #esconde mensajes innecesarios del log
  gem 'quiet_assets'
  #errores con consola en browser
  gem 'binding_of_caller'
  #impresion amigable en consola
  gem 'awesome_print'
  #generador de modelo relación-entidad
  #Descomentar sólo para casos puntuales
  #gem "rails-erd"
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'selenium-webdriver', '~> 2.45.0'
end

#Accounts, Permissions, Roles:
#cuentas
gem 'devise'
#permisos
gem 'cancan'
#roles
#gem 'rolify'
#validacion de emails
#gem 'validates_email_format_of'

#Formularios simples
# gem 'simple_form'

#Mandrill mailer
gem 'mandrill-api'

#Por si queremos generar breadcrums fácilmente
#gem "breadcrumbs_on_rails"

#Por si queremos paginación fácil
gem 'will_paginate-bootstrap'

#Por si queremos gráficos
#gem 'lazy_high_charts'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# Pago en linea: Punto Pagos
gem 'puntopagos'

# Legacy
# Importacion de datos desde excel
gem 'roo'
gem 'roo-xls'

#New for spreadsheets
#gem 'roo', '~> 2.3.2'
#gem 'roo-xls'

# File Upload
# gem 'rmagick'
gem "mini_magick"
gem 'carrierwave'
gem "fog"

# Calendar
gem 'ri_cal'

# Version Movil
gem 'mobu'

# Gráficos Reporting Javascript
gem "chartkick"

# Agrupación de elementos por fecha
gem 'groupdate'

# PDF
gem 'prawn'
gem 'prawn-table'

# Facebook
gem "fbgraph"
gem "fb_graph"

# Advertencias en validaciones
# gem 'validation_scopes'
gem 'validation_scopes', :git => 'https://github.com/ivalkeen/validation_scopes.git'

#Librería para string matching
gem 'amatch'

#Capistrano para deploy
gem 'capistrano', '~> 3.1.0'
gem 'capistrano-bundler', '~> 1.1.2'
gem 'capistrano-rails', '~> 1.1.1'
gem 'capistrano-rvm', github: "capistrano/rvm"
gem 'capistrano3-delayed-job', '~> 1.0'

# Editor de texto tipo word
gem 'ckeditor'

# Para ejecutar tareas asíncronas o programadas en segundo plano.
gem 'delayed_job_active_record'

# Para demonizar las tareas en segundo plano.
gem "daemons"

#pg_search para búsqueda utilizando extensiones de Postgres
gem 'pg_search'

#Librería para generar datos para el seed
gem 'faker'

#New Relic
gem 'newrelic_rpm'

#Facebook and Google login
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'

#Geocoder para localizacion por IP
gem 'geocoder'

#Gema para CORS API
gem 'rack-cors'

#Oink para revisión de memoria
gem "oink"

# CSS Preprocessor
gem 'sass-rails'
#gem 'compass-rails'

#Squirm-rails for stored procedures
#gem "squirm_rails", require: "squirm/rails"

#Amazon Web Service SDK
gem 'aws-sdk', '~> 2'

#Mysql2 para migración
gem 'mysql2'

#Gem for writing real excel files
gem 'writeexcel'

#Parses para postgres
gem 'pg_array_parser'

#validador de correos
gem 'rfc822'

#Lista de licencias
group :development, :test do
  gem 'gem-licenses'
  gem 'license-list', '~> 1.0', '>= 1.0.1'
end
