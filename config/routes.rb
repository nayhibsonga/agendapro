Agendapro::Application.routes.draw do


  resources :deals

  get "users/index"
  require 'subdomain'

  # Mandrill
  get 'mandrill/confirm_unsubscribe', :as => 'unsubscribe'
  post "mandrill/unsubscribe"
  get "mandrill/resuscribe"

  devise_for :users, controllers: {registrations: 'registrations', :omniauth_callbacks => "omniauth_callbacks"}
  resources :countries
  resources :regions
  resources :cities
  resources :districts

  resources :tags
  resources :statuses
  resources :economic_sectors
  resources :economic_sectors_dictionaries
  resources :company_settings
  resources :payment_statuses
  resources :roles
  resources :plans
  resources :staff_times
  resources :location_times

  resources :companies
  resources :locations
  resources :services
  resources :promotions
  resources :bookings
  resources :service_providers
  resources :service_categories
  resources :resources
  resources :clients
  resources :resource_categories
  resources :resources
  resources :company_from_emails
  resources :staff_codes
  resources :billing_infos

  resources :numeric_parameters

  resources :clients
  resources :deals

  resources :payed_bookings
  resources :banks

  namespace :admin do
    get '', :to => 'dashboard#index', :as => '/'
    resources :users
  end

  # Quick Add
  get '/quick_add', :to => 'quick_add#quick_add', :as => 'quick_add'
    # Validation
  post '/quick_add/location_valid', :to => 'quick_add#location_valid'
  post '/quick_add/services_valid', :to => 'quick_add#services_valid'
  post '/quick_add/service_provider_valid', :to => 'quick_add#service_provider_valid'
    # POST
  post '/quick_add/location', :to => 'quick_add#create_location'
  post '/quick_add/services', :to => 'quick_add#create_services'
  post '/quick_add/service_provider', :to => 'quick_add#create_service_provider'
  patch '/quick_add/update_company', :to => 'quick_add#update_company'
  #post '/quick_add/update_settings', :to => 'quick_add#update_settings'

  # Reporting
  get '/dashboard', :to => 'dashboard#index', :as => 'dashboard'
  get '/reports', :to => 'reports#index', :as => 'reports'
  get '/report_locations', :to => 'reports#locations'
  get '/report_services', :to => 'reports#services'
  get '/report_statuses', :to => 'reports#statuses'
  get '/report_status_details', :to => 'reports#status_details'
  get '/report_location_services/:id', :to => 'reports#location_services'
  get '/report_location_providers/:id', :to => 'reports#location_providers'
  get '/report_location_comission/:id', :to => 'reports#location_comission'
  get '/report_provider_services/:id', :to => 'reports#provider_services'

  #
  post '/client_comments', :to => 'clients#create_comment', :as => 'client_comments'
  get '/select_plan', :to => 'plans#select_plan', :as => 'select_plan'
  get '/get_direction', :to => 'districts#get_direction'
  get '/time_booking_edit', :to => 'company_settings#time_booking_edit', :as => 'time_booking'
  get '/minisite/:id', :to => 'company_settings#minisite', :as => 'minisite'
  get '/compose_mail', :to => 'clients#compose_mail', :as => 'send_mail'
  post '/send_mail_client', :to => 'clients#send_mail'
  get '/get_link', :to => 'companies#get_link', :as => 'get_link'
  post '/change_categories_order', :to => 'service_categories#change_categories_order'
  post '/change_services_order', :to => 'services#change_services_order'
  post '/change_location_order', :to => 'locations#change_location_order'
  post '/change_providers_order', :to => 'service_providers#change_providers_order'
  get '/confirm_email', :to => 'company_from_emails#confirm_email', :as => 'confirm_email'

  # Autocompletar del Booking
  get '/clients_suggestion', :to => 'clients#suggestion'
  get '/clients_name_suggestion', :to => 'clients#name_suggestion'
  get '/clients_last_name_suggestion', :to => 'clients#last_name_suggestion'
  get '/clients_rut_suggestion', :to => 'clients#rut_suggestion'
  get '/client_loader', :to => 'clients#client_loader'

  get '/check_staff_code', :to => 'staff_codes#check_staff_code'

  get '/provider_services', :to => 'service_providers#provider_service'

  # Singup Validations
  get '/check_user', :to => 'users#check_user_email'
  get '/check_company', :to => 'companies#check_company_web_address'

  # My Agenda
  get '/my_agenda', :to => 'users#agenda', :as => 'my_agenda'

  # Add Company from Usuario Registrado
  get '/add_company', :to => 'companies#add_company', :as => 'add_company'

  get "/home", :to => 'home#index', :as => 'home'
  get "/features", :to => 'home#features', :as => 'features'
  get "/view_plans", :to => 'plans#view_plans', :as => 'view_plans'
  get "/about_us", :to => 'home#about_us',  :as => 'aboutus'
  get "/tutorials", :to => 'home#tutorials',  :as => 'tutorials'
  get "/contact", :to => 'home#contact', :as => 'contact'
  post "/pcontact", :to => 'home#post_contact'
  get '/mobile_contact', :to => 'home#mobile_contact'
  post '/mobile_contact', :to => 'home#mobile_contact'

  # Punto Pagos
  get "/punto_pagos/generate_transaction/:mp/:amount", :to => 'punto_pagos#generate_transaction', :as => 'punto_pagos_generate'
  get "/punto_pagos/generate_company_transaction/:mp/:amount", :to => 'punto_pagos#generate_company_transaction', :as => 'generate_company_transaction'
  get "/punto_pagos/generate_plan_transaction/:mp/:plan_id", :to => 'punto_pagos#generate_plan_transaction', :as => 'generate_plan_transaction'
  post "/punto_pagos/notification", :to => 'punto_pagos#notification', :as => 'punto_pagos_notification'
  get "/punto_pagos/success", :to => 'punto_pagos#success', :as => 'punto_pagos_success'
  get "/punto_pagos/failure", :to => 'punto_pagos#failure', :as => 'punto_pagos_failure'
  post "/punto_pagos/notification/:trx", :to => 'punto_pagos#notification', :as => 'punto_pagos_notification_trx'
  get "/punto_pagos/success/:token", :to => 'punto_pagos#success', :as => 'punto_pagos_success_trx'
  get "/punto_pagos/failure/:token", :to => 'punto_pagos#failure', :as => 'punto_pagos_failure_trx'
  get "/companies/:id/edit_payment", :to => 'companies#edit_payment', :as => 'edit_payment_company'
  get "/logs/puntopagos_creations", :to => 'plans#puntopagos_creations', :as => 'puntopagos_creations'
  get "/logs/puntopagos_confirmations", :to => 'plans#puntopagos_confirmations', :as => 'puntopagos_confirmations'
  get "/logs/company_cron_logs", :to => 'plans#company_cron_logs', :as => 'company_cron_logs'
  get "/logs/plan_logs", :to => 'plans#plan_logs', :as => 'plan_logs'
  get "/logs/billing_logs", :to => 'plans#billing_logs', :as => 'billing_logs'
  get "/company/:id/add_month", :to => 'companies#add_month', :as => 'add_month'
  get "/companies_payments", :to => 'companies#manage'
  get "/manage_company/:id", :to => 'companies#manage_company'
  get "/companies/new_payment/:id", :to => 'companies#new_payment'
  post "/companies/add_payment", :to => 'companies#add_payment'
  post "/companies/delete_payment", :to => 'companies#delete_payment'
  get "/companies/payment/:id", :to => 'companies#payment'
  post "/companies/modify_payment", :to => 'companies#modify_payment'
  get "/get_year_incomes", :to => 'companies#get_year_incomes'
  get "/get_year_bookings", :to => 'companies#get_year_bookings'
  get '/companies_incomes', :to => 'companies#incomes'
  get '/companies_locations', :to => 'companies#locations'
  get '/companies_monthly_locations', :to => 'companies#monthly_locations'
  get '/companies_monthly_bookings', :to => 'companies#monthly_bookings'
  post '/companies/update_company', :to => 'companies#update_company'
  post '/companies/deactivate_company', :to => 'companies#deactivate_company'
  post '/companies/get_monthly_bookings', :to => 'companies#get_monthly_bookings'

  # Search
  get "searchs/index"
  get '/search', :to => "searchs#search"
  get '/get_districts', :to => 'districts#get_districts'
  get '/get_input_districts', :to => 'districts#get_input_districts'
  get '/get_district', :to => 'districts#get_district'
  get '/district_by_name', :to => 'districts#get_district_by_name'

  # Workflow
  # Workflow - overview
  get '/schedule', :to => 'location_times#schedule_local'
  get '/local', :to => 'locations#location_data'
  get '/local_districts', :to => 'locations#location_districts'
  # Workflow - wizard
  get '/workflow', :to => 'companies#workflow', :as => 'workflow'
  get '/local_services', :to => 'services#location_categorized_services'
  get '/location_services', :to => 'services#location_services'
  get '/local_providers', :to => 'service_providers#location_providers'
  get '/providers_services', :to => 'services#get_providers'
  get '/location_time', :to => 'locations#location_time'
  get '/get_booking', :to => 'bookings#get_booking'
  get '/get_booking_info', :to => 'bookings#get_booking_info'
  post "/book", :to => 'bookings#book_service'
  get '/book_error', :to => 'bookings#book_error', :as => 'book_error'
  post '/remove_bookings', :to => 'bookings#remove_bookings'
  get '/get_available_time', :to => 'locations#get_available_time'
  get '/check_user_cross_bookings', :to => 'bookings#check_user_cross_bookings'
  get '/optimizer_hours', :to => 'bookings#optimizer_hours'
  post '/optimizer_data', :to => 'bookings#optimizer_data'
  # Workflow - Mobile
  post '/select_hour', :to => 'companies#select_hour'
  post '/user_data', :to => 'companies#user_data'

  # Fullcalendar
  get '/service', :to => 'services#service_data'  # Fullcalendar
  get '/services_list', :to => 'services#services_data'  # Fullcalendar
  get '/provider_time', :to => 'service_providers#provider_time'  # Fullcalendar
  get '/booking', :to => 'bookings#provider_booking'  # Fullcalendar
  get '/provider_breaks', :to => 'provider_breaks#provider_breaks', :as => 'provider_breaks'
  get '/provider_breaks/:id', :to => 'provider_breaks#get_provider_break', :as => 'get_provider_break'
  post '/provider_breaks', :to => 'provider_breaks#create_provider_break', :as => 'create_provider_breaks'
  patch '/provider_breaks/:id', :to => 'provider_breaks#update_provider_break', :as => 'edit_provider_break'
  delete '/provider_breaks/:id', :to => 'provider_breaks#destroy_provider_break', :as => 'delete_provider_break'
  get '/available_providers', :to => 'service_providers#available_providers', :as => 'available_service_providers'
  get '/clients_bookings_history', :to => 'clients#bookings_history'
  get '/booking_history', :to => 'bookings#booking_history'
  get '/fixed_bookings', :to => 'bookings#fixed_index', :as => 'fixed_bookings'
  post '/booking_valid', :to => 'bookings#booking_valid'
  post '/force_create', :to => 'bookings#force_create'

  get '/edit_booking', :to => 'bookings#edit_booking', :as => 'booking_edit'
  post '/edited_booking', :to => 'bookings#edit_booking_post'
  get '/cancel_booking', :to => 'bookings#cancel_booking', :as => 'booking_cancel'
  get '/transfer_cancel', :to => 'bookings#transfer_error_cancel'
  post '/cancel_booking', :to => 'bookings#cancel_booking'
  get '/cancel_all_booking', :to => 'bookings#cancel_all_booking', :as => 'cancel_all_booking'
  post '/cancel_all_booking', :to => 'bookings#cancel_all_booking'
  get '/confirm_booking', :to => 'bookings#confirm_booking', :as => 'confirm_booking'
  get '/blocked_edit', :to => 'bookings#blocked_edit', :as => 'blocked_edit'
  get '/blocked_cancel', :to => 'bookings#blocked_cancel', :as => 'blocked_cancel'

  post '/clients/:id/comments', :to => 'clients#create_comment'
  patch '/clients/:id/comments', :to => 'clients#update_comment'
  delete '/clients/:id/comments', :to => 'clients#destroy_comment'

  get '/inactive_locations', :to => 'locations#inactive_index', :as => 'inactive_locations'
  get '/inactive_services', :to => 'services#inactive_index', :as => 'inactive_services'
  get '/inactive_service_providers', :to => 'service_providers#inactive_index', :as => 'inactive_service_providers'

  get '/companies/:id/activate', :to => 'companies#activate', :as => 'activate_company'
  get '/locations/:id/activate', :to => 'locations#activate', :as => 'activate_location'
  get '/services/:id/activate', :to => 'services#activate', :as => 'activate_service'
  get '/service_providers/:id/activate', :to => 'service_providers#activate', :as => 'activate_service_provider'

  get '/companies/:id/deactivate', :to => 'companies#deactivate', :as => 'deactivate_company'
  get '/locations/:id/deactivate', :to => 'locations#deactivate', :as => 'deactivate_location'
  get '/services/:id/deactivate', :to => 'services#deactivate', :as => 'deactivate_service'
  get '/service_providers/:id/deactivate', :to => 'service_providers#deactivate', :as => 'deactivate_service_provider'
  post '/clients/import', :to => 'clients#import', :as => 'import_clients'
  get '/clients/:id/history', :to => 'clients#history', :as => 'client_history'

  get '/country_regions', :to => 'regions#country_regions'
  get '/region_cities', :to => 'cities#region_cities'
  get '/city_districs', :to => 'districts#city_districs'

  get '/service_provider/pdf', :to => 'service_providers#pdf'
  get '/provider_hours', :to => 'bookings#provider_hours'

  get '/iframe/sampler', :to => 'iframe#sampler'
  post '/iframe/overview/:company_id', :to => 'iframe#overview'
  post '/iframe/overview', :to => 'iframe#overview'
  get '/iframe/overview/:company_id', :to => 'iframe#overview'
  get '/iframe/overview', :to => 'iframe#overview'
  get '/iframe/workflow/:location_id', :to => 'iframe#workflow'
  post '/iframe/book_service', :to => 'iframe#book_service'
  get '/iframe/construction', :to => 'iframe#construction', :as => 'iframe_construction'
  get '/iframe/facebook_setup', :to => 'iframe#facebook_setup', :as => 'facebook_setup'
  post '/iframe/facebook_submit', :to => 'iframe#facebook_submit', :as => 'facebook_submit'
  patch '/iframe/facebook_submit', :to => 'iframe#facebook_submit', :as => 'facebook_submit_edit'
  get '/iframe/facebook_success', :to => 'iframe#facebook_success', :as => 'facebook_success'
  get '/iframe/facebook_addtab', :to => 'iframe#facebook_addtab', :as => 'facebook_addtab'
  get '/company_settings/:id/delete_facebook_pages', :to => 'company_settings#delete_facebook_pages', :as => 'delete_facebook_pages'

  post '/company_settings/update_payment', :to => 'company_settings#update_payment'

  # Payed Bookings
  get "/company_bookings", :to => 'payed_bookings#show'
  post "payed_bookings/create_csv", :to => 'payed_bookings#create_csv'
  post "payed_bookings/create_company_csv", :to => 'payed_bookings#create_company_csv'
  post "payed_bookings/mark_as_payed", :to => 'payed_bookings#mark_as_payed'
  post "payed_bookings/unmark_as_payed", :to => 'payed_bookings#unmark_as_payed'
  post "payed_bookings/mark_several_as_payed", :to => 'payed_bookings#mark_several_as_payed'
  post "payed_bookings/unmark_several_as_payed", :to => 'payed_bookings#unmark_several_as_payed'
  post "payed_bookings/mark_canceled_as_payed", :to => 'payed_bookings#mark_canceled_as_payed'
  post "payed_bookings/unmark_canceled_as_payed", :to => 'payed_bookings#unmark_canceled_as_payed'
  post "payed_bookings/mark_several_canceled_as_payed", :to => 'payed_bookings#mark_several_canceled_as_payed'
  post "payed_bookings/unmark_several_canceled_as_payed", :to => 'payed_bookings#unmark_several_canceled_as_payed'
  post "payed_bookings/update", :to => 'payed_bookings#update'

  # Root
  get '/' => 'searchs#index', :constraints => { :subdomain => 'www' }
  get '/' => 'companies#overview', :constraints => { :subdomain => /.+/ }

  root :to => 'searchs#index'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
