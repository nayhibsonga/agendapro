Agendapro::Application.routes.draw do

  devise_for :users, skip: [:session, :password, :registration, :confirmation], :controllers => { omniauth_callbacks: "omniauth_callbacks" }

  scope "(:locale)", locale: /es|es_CL|es_CO|es_PA|es_VE|es_GT/ do

    # devise_for :users, controllers: {registrations: 'registrations', omniauth_callbacks: "omniauth_callbacks"}

    devise_for :users, skip: [:omniauth_callbacks], controllers: {registrations: 'registrations'}

    get "users/index"
    require 'subdomain'

    # Mandrill
    get 'mandrill/confirm_unsubscribe', :as => 'unsubscribe'
    post "mandrill/unsubscribe"
    get "mandrill/resuscribe"

    resources :company_plan_settings
    resources :attribute_categories
    resources :attributes

    resources :countries
    resources :regions
    resources :cities
    resources :districts

    resources :tags
    resources :statuses
    resources :marketplace_categories
    resources :economic_sectors
    resources :economic_sectors_dictionaries
    resources :company_settings
    resources :payment_statuses
    resources :roles
    resources :plans
    resources :staff_times
    resources :location_times
    resources :notification_emails

    resources :companies
    resources :locations
    resources :services
    resources :bundles
    resources :promotions
    resources :bookings
    resources :service_providers
    resources :service_categories
    resources :provider_groups
    resources :resources
    resources :clients
    resources :resource_categories
    resources :resources
    resources :company_from_emails
    resources :staff_codes
    resources :billing_infos

    resources :numeric_parameters

    resources :deals

    resources :payed_bookings
    resources :banks

    resources :payments
    resources :payment_method_types
    resources :receipt_types
    resources :company_payment_methods
    resources :payment_methods

    resources :product_categories

    resources :product_brands

    resources :product_displays

    resources :products

    resources :favorite_locations, only: [:index, :create, :destroy]

    resources :cashiers

    resources :client_files

    resources :company_files

    namespace :admin do
      get '', :to => 'dashboard#index', :as => '/'
      resources :users
    end

    # Quick Add
    get '/quick_add', :to => 'quick_add#quick_add', :as => 'quick_add'
    get '/quick_add/load_location/:id', :to => 'quick_add#load_location'
      # Validation
    # post '/quick_add/location_valid', :to => 'quick_add#location_valid'
    # post '/quick_add/services_valid', :to => 'quick_add#services_valid'
    # post '/quick_add/service_provider_valid', :to => 'quick_add#service_provider_valid'
      # POST
    post '/quick_add/location', :to => 'quick_add#create_location'
    patch '/quick_add/location/:id', :to => 'quick_add#update_location'
    post '/quick_add/service_category', :to => 'quick_add#create_service_category'
    delete '/quick_add/service_category/:id', :to => 'quick_add#delete_service_category'
    post '/quick_add/service', :to => 'quick_add#create_service'
    delete '/quick_add/service/:id', :to => 'quick_add#delete_service'
    post '/quick_add/service_provider', :to => 'quick_add#create_service_provider'
    delete '/quick_add/service_provider/:id', :to => 'quick_add#delete_service_provider'
    patch '/quick_add/update_company', :to => 'quick_add#update_company'

    post '/create_notification_email', :to => 'quick_add#create_notification_email'
    post '/delete_notification_email', :to => 'quick_add#delete_notification_email'
    patch '/save_configurations', :to => 'quick_add#save_configurations'

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
    # get '/time_booking_edit', :to => 'company_settings#time_booking_edit', :as => 'time_booking'
    # get '/minisite', :to => 'company_settings#minisite', :as => 'minisite'

    get '/get_link', :to => 'companies#get_link', :as => 'get_link'
    post '/change_categories_order', :to => 'service_categories#change_categories_order'
    post '/change_services_order', :to => 'services#change_services_order'
    post '/change_location_order', :to => 'locations#change_location_order'
    post '/change_providers_order', :to => 'service_providers#change_providers_order'
    post '/change_groups_order', :to => 'provider_groups#change_groups_order'
    get '/confirm_email', :to => 'company_from_emails#confirm_email', :as => 'confirm_email'

    # Mail Composing
    scope controller: 'clients' do
      get '/compose_mail', action: 'compose_mail', as: 'send_mail'
      post '/send_mail_client', action: 'send_mail'
    end

    # Mail Editor
    namespace 'email' do
      scope controller: 'content', path: '/content' do
        post '/editor', action: 'editor', as: :editor
        post "/update", action: 'update', as: :update
        post "/upload", action: 'upload', as: :upload
      end
    end

    # Autocompletar del Booking
    get '/clients_suggestion', :to => 'clients#suggestion'
    get '/clients_name_suggestion', :to => 'clients#name_suggestion'
    get '/clients_last_name_suggestion', :to => 'clients#last_name_suggestion'
    get '/clients_rut_suggestion', :to => 'clients#rut_suggestion'
    get '/client_loader', :to => 'clients#client_loader'

    get '/check_staff_code', :to => 'staff_codes#check_staff_code'
    get '/get_staff_by_code', :to => 'staff_codes#get_staff_by_code'

    get '/provider_services', :to => 'service_providers#provider_service'

    # Singup Validations
    get '/check_user', :to => 'users#check_user_email'
    get '/check_company', :to => 'companies#check_company_web_address'

    # My Agenda
    get '/my_agenda', :to => 'users#agenda', :as => 'my_agenda'
    get '/get_session_bookings', :to => 'users#get_session_bookings'
    get '/get_session_summary', :to => 'users#get_session_summary'

    scope controller: 'bookings' do
      post '/delete_session_booking', action: 'delete_session_booking'
      post '/validate_session_booking', action: 'validate_session_booking'
      post '/validate_session_form', action: 'validate_session_form'
      get '/validate_session_form', action: 'validate_session_form'
      get '/session_booking_detail', action: 'session_booking_detail'
      get '/book_session_form', action: 'book_session_form'
      post '/update_book_session', action: 'update_book_session'
      get '/sessions_calendar', action: 'sessions_calendar'
    end



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
    get "/punto_pagos/generate_company_transaction/:mp/:amount", :to => 'punto_pagos#generate_company_transaction', :as => 'pp_generate_company_transaction'
    get "/punto_pagos/generate_plan_transaction/:mp/:plan_id", :to => 'punto_pagos#generate_plan_transaction', :as => 'pp_generate_plan_transaction'
    get "/punto_pagos/generate_reactivation_transaction/:mp", :to => 'punto_pagos#generate_reactivation_transaction', :as => 'pp_generate_reactivation_transaction'
    post "/punto_pagos/notification", :to => 'punto_pagos#notification', :as => 'punto_pagos_notification'
    get "/punto_pagos/success", :to => 'punto_pagos#success', :as => 'punto_pagos_success'
    get "/punto_pagos/failure", :to => 'punto_pagos#failure', :as => 'punto_pagos_failure'
    post "/punto_pagos/notification/:trx", :to => 'punto_pagos#notification', :as => 'punto_pagos_notification_trx'
    get "/punto_pagos/success/:token", :to => 'punto_pagos#success', :as => 'punto_pagos_success_trx'
    get "/punto_pagos/failure/:token", :to => 'punto_pagos#failure', :as => 'punto_pagos_failure_trx'
    get "/pay_u/generate_transaction", :to => 'pay_u#generate_transaction', :as => 'pay_u_generate'
    get "/pay_u/generate_company_transaction/:amount", :to => 'pay_u#generate_company_transaction', :as => 'pu_generate_company_transaction'
    get "/pay_u/generate_plan_transaction/:plan_id", :to => 'pay_u#generate_plan_transaction', :as => 'pu_generate_plan_transaction'
    get "/pay_u/generate_reactivation_transaction", :to => 'pay_u#generate_reactivation_transaction', :as => 'pu_generate_reactivation_transaction'
    post "/pay_u/confirmation", :to => 'pay_u#confirmation', :as => 'pay_u_confirmation'
    get "/pay_u/response", :to => 'pay_u#response_handler', :as => 'pay_u_response'
    get "/pay_u/success", :to => 'pay_u#success', :as => 'pay_u_success'
    get "/pay_u/failure", :to => 'pay_u#failure', :as => 'pay_u_failure'
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
    post '/save_billing_wire_transfer', :to => 'plans#save_billing_wire_transfer'
    get '/pending_billing_wire_transfers', :to => 'companies#pending_billing_wire_transfers'
    get '/approved_billing_wire_transfers', :to => 'companies#approved_billing_wire_transfers'
    get '/show_billing_wire_transfer', :to => 'companies#show_billing_wire_transfer'
    post '/approve_billing_wire_transfer', :to => 'companies#approve_billing_wire_transfer'
    post '/delete_billing_wire_transfer', :to => 'companies#delete_billing_wire_transfer'

    # Search
    get "searchs/index"
    get '/search', :to => "searchs#search"
    get '/get_districts', :to => 'districts#get_districts'
    get '/get_input_districts', :to => 'districts#get_input_districts'
    get '/get_district', :to => 'districts#get_district'
    get '/district_by_name', :to => 'districts#get_district_by_name'

    # Promotions
    get '/get_promotions', :to => 'searchs#promotions'
    get '/get_last_minute_promotions', :to => 'searchs#last_minute_promotions'
    get '/get_treatment_promotions', :to => 'searchs#treatment_promotions'
    get '/manage_promotions', :to => 'services#manage_promotions'
    get '/manage_service_promotion', :to => 'services#manage_service_promotion'
    get '/manage_treatment_promotion', :to => 'services#manage_treatment_promotion'

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
    get '/get_booking_for_payment', :to => 'bookings#get_booking_for_payment'
    get '/get_session_booking_for_payment', :to => 'bookings#get_session_booking_for_payment'
    get "/book", :to => 'bookings#book_service'
    post "/book", :to => 'bookings#book_service'
    get '/book_error', :to => 'bookings#book_error', :as => 'book_error'
    post '/remove_bookings', :to => 'bookings#remove_bookings'
    get '/get_available_time', :to => 'locations#get_available_time'
    get '/check_user_cross_bookings', :to => 'bookings#check_user_cross_bookings'
    get '/optimizer_hours', :to => 'bookings#optimizer_hours'
    post '/optimizer_data', :to => 'bookings#optimizer_data'
    get '/available_hours_week_html', :to => 'service_providers#available_hours_week_html'
    # Workflow - Mobile
    get '/select_hour', :to => 'companies#select_hour'
    get '/select_promo_hour', :to => 'companies#select_promo_hour'
    post '/select_session_hour', :to => 'companies#select_session_hour'
    get '/user_data', :to => 'companies#user_data'
    get '/mobile_hours', :to => 'companies#mobile_hours'

    # Fullcalendar
    get '/provider_breaks/new', :to => 'provider_breaks#new', :as => 'new_provider_break'
    get '/service', :to => 'services#service_data'  # Fullcalendar
    get '/services_list', :to => 'services#services_data'  # Fullcalendar
    get '/provider_time', :to => 'service_providers#provider_time'  # Fullcalendar
    get '/booking', :to => 'bookings#provider_booking'  # Fullcalendar
    get '/provider_breaks', :to => 'provider_breaks#provider_breaks', :as => 'provider_breaks'
    get '/provider_breaks/:id', :to => 'provider_breaks#get_provider_break', :as => 'get_provider_break'
    post '/provider_breaks', :to => 'provider_breaks#create_provider_break', :as => 'create_provider_breaks'
    patch '/provider_breaks/:id', :to => 'provider_breaks#update_provider_break', :as => 'edit_provider_break'
    delete '/provider_breaks/:id', :to => 'provider_breaks#destroy_provider_break', :as => 'delete_provider_break'
    post '/provider_breaks/update_repeat_break', :to => 'provider_breaks#update_repeat_break', :as => 'update_repeat_break'
    post '/provider_breaks/destroy_repeat_break', :to => 'provider_breaks#destroy_repeat_break', :as => 'destroy_repeat_break'
    get '/available_providers', :to => 'service_providers#available_providers', :as => 'available_service_providers'
    get '/clients_bookings_history', :to => 'clients#bookings_history'
    get '/clients_check_sessions', :to => 'clients#check_sessions'
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
    get '/cancel_all_reminded_booking', :to => 'bookings#cancel_all_reminded_booking', :as => 'cancel_all_reminded_booking'
    post '/cancel_all_reminded_booking', :to => 'bookings#cancel_all_reminded_booking'
    get '/confirm_booking', :to => 'bookings#confirm_booking', :as => 'confirm_booking'
    get '/confirm_all_bookings', :to => 'bookings#confirm_all_bookings', :as => 'confirm_all_bookings'
    get '/confirm_error', :to => 'bookings#confirm_error', :as => 'confirm_error'
    get '/confirm_success', :to => 'bookings#confirm_success', :as => 'confirm_success'
    get '/blocked_edit', :to => 'bookings#blocked_edit', :as => 'blocked_edit'
    get '/blocked_cancel', :to => 'bookings#blocked_cancel', :as => 'blocked_cancel'

    post '/clients/:id/comments', :to => 'clients#create_comment'
    patch '/clients/:id/comments', :to => 'clients#update_comment'
    delete '/clients/:id/comments', :to => 'clients#destroy_comment'

    get '/inactive_locations', :to => 'locations#inactive_index', :as => 'inactive_locations'
    get '/inactive_services', :to => 'services#inactive_index', :as => 'inactive_services'
    get '/inactive_service_providers', :to => 'service_providers#inactive_index', :as => 'inactive_service_providers'

    patch '/companies/:id/activate', :to => 'companies#activate', :as => 'activate_company'
    patch '/locations/:id/activate', :to => 'locations#activate', :as => 'activate_location'
    patch '/services/:id/activate', :to => 'services#activate', :as => 'activate_service'
    patch '/service_providers/:id/activate', :to => 'service_providers#activate', :as => 'activate_service_provider'
    patch '/staff_codes/:id/activate', :to => 'staff_codes#activate', :as => 'activate_staff_code'

    patch '/companies/:id/deactivate', :to => 'companies#deactivate', :as => 'deactivate_company'
    patch '/locations/:id/deactivate', :to => 'locations#deactivate', :as => 'deactivate_location'
    patch '/services/:id/deactivate', :to => 'services#deactivate', :as => 'deactivate_service'
    patch '/service_providers/:id/deactivate', :to => 'service_providers#deactivate', :as => 'deactivate_service_provider'
    patch '/staff_codes/:id/deactivate', :to => 'staff_codes#deactivate', :as => 'deactivate_staff_code'
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
    delete '/company_settings/:id/delete_facebook_pages', :to => 'company_settings#delete_facebook_pages', :as => 'delete_facebook_pages'
    get '/iframe/book_error', :to => 'iframe#book_error', :as => 'iframe_book_error'

    post '/company_settings/update_payment', :to => 'company_settings#update_payment'
    patch '/company_payment_methods/:id/activate', :to => 'company_payment_methods#activate', :as => 'activate_company_payment_method'
    patch '/company_payment_methods/:id/deactivate', :to => 'company_payment_methods#deactivate', :as => 'deactivate_company_payment_method'
    get '/booking_payment', :to => 'payments#booking_payment'
    get '/load_payment', :to => 'payments#load_payment'
    get '/past_bookings', :to => 'payments#past_bookings'
    get '/past_sessions', :to => 'payments#past_sessions'
    get 'payment_client_bookings', :to => 'payments#client_bookings'
    get 'payment_client_sessions', :to => 'payments#client_sessions'
    get '/payments_index_content', :to=> 'payments#index_content'
    post '/create_new_payment', :to => 'payments#create_new_payment'

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

    # Promotions
    post "/set_service_promotions", :to => 'services#set_promotions'
    post '/set_service_promo_times', :to => 'services#set_service_promo_times'
    get "/get_promotions_popover", :to => 'services#get_promotions_popover'
    get "/get_online_discount_popover", :to => 'services#get_online_discount_popover'
    get "/promotion_hours", :to => 'bookings#promotion_hours'
    #post '/admin_update_promo', :to => 'services#admin_update_promo'
    get "/show_time_promo", :to => 'services#show_time_promo'
    get '/show_last_minute_promo', :to => 'services#show_last_minute_promo'
    get '/show_treatment_promo', :to => 'services#show_treatment_promo'
    get '/last_minute_hours', :to => 'services#last_minute_hours'

    # Root
    get '', :to => 'searchs#index', :as => 'localized_root2', :constraints => { :subdomain => 'www' }
    get '', :to => 'companies#overview', :constraints => { :subdomain => /.+/ }
    get '', :to => 'searchs#index', :as => 'localized_root'
    get 'landing', :to => 'searchs#landing', :as => 'landing'

    # PuntoPagos Local
    post "/transaccion/crear", :to => 'local_punto_pagos#create_transaction'
    get "/transaccion/crear", :to => 'local_punto_pagos#create_transaction'
    get "/transaccion/procesar/:token", :to => 'local_punto_pagos#process_transaction'
    post "/transaccion/notificar", :to => 'local_punto_pagos#notify'

    # Caja
    get "/location_products", :to => 'locations#location_products'
    get '/alarm_form', :to => 'products#alarm_form'
    get '/inventory', :to => 'locations#inventory'
    post '/set_alarm', :to => 'products#set_alarm'
    post '/products/import', :to => 'products#import', :as => 'import_products'
    get '/company_inventory', :to => 'companies#inventory'
    get '/company_alarms', :to => 'companies#stock_alarm_form'
    get '/location_alarms', :to => 'locations#stock_alarm_form'
    post '/save_alarms', :to => 'locations#save_stock_alarm'
    get '/location_sellers', :to => 'locations#sellers'

    patch '/cashiers/:id/activate', :to => 'cashiers#activate', :as => 'activate_cashier'
    patch '/cashiers/:id/deactivate', :to => 'cashiers#deactivate', :as => 'deactivate_cashier'
    get '/get_cashier_by_code', :to => 'cashiers#get_by_code'

    get '/receipt_pdf', :to => 'payments#receipt_pdf'
    get '/payment_pdf', :to => 'payments#payment_pdf'

    post '/receipts_email', :to => 'payments#send_receipts_email'
    get '/payment_receipts', :to => 'payments#get_receipts'

    get '/payment_intro', :to => 'payments#get_intro_info'
    post '/save_payment_intro', :to => 'payments#save_intro_info'

    post '/update_payment', :to => 'payments#update_payment'

    get '/check_booking_payment', :to => 'payments#check_booking_payment'
    get '/get_formatted_booking', :to => 'payments#get_formatted_booking'

    post '/delete_payment', :to => 'payments#delete_payment'

    #Internal Sale
    post '/save_internal_sale', :to => 'payments#save_internal_sale'
    post '/delete_internal_sale', :to => 'payments#delete_internal_sale'
    get '/get_internal_sale', :to => 'payments#get_internal_sale'
    get '/get_product_for_payment_or_sale', :to => 'payments#get_product_for_payment_or_sale'

    #ServiceCommissions
    get '/commissions', :to => 'payments#commissions'
    get '/service_commissions', :to => 'payments#service_commissions'
    get '/provider_commissions', :to => 'payments#provider_commissions'
    post '/set_commissions', :to => 'payments#set_commissions'
    post '/set_default_commission', :to => 'payments#set_default_commission'
    post '/set_provider_default_commissions', :to => 'payments#set_provider_default_commissions'
    get '/commissions_content', :to => 'payments#commissions_content'

    #PettyCash
    get '/petty_cash', :to => 'payments#petty_cash'
    get '/petty_transactions', :to => 'payments#petty_transactions'
    get '/petty_transaction', :to => 'payments#petty_transaction'
    post '/add_petty_transaction', :to => 'payments#add_petty_transaction'
    post '/open_close_petty_cash', :to => 'payments#open_close_petty_cash'
    post '/delete_petty_transaction', :to => 'payments#delete_petty_transaction'
    post '/set_petty_cash_close_schedule', :to => 'payments#set_petty_cash_close_schedule'

    #SalesCash
    get '/sales_cash', :to => 'payments#sales_cash'
    get '/sales_cash_content', :to => 'payments#sales_cash_content'
    get '/get_sales_cash', :to => 'payments#get_sales_cash'
    post '/save_sales_cash', :to => 'payments#save_sales_cash'
    post '/close_sales_cash', :to => 'payments#close_sales_cash'

    #SalesCashTransactions
    get '/get_sales_cash_transaction', :to => 'payments#get_sales_cash_transaction'
    post '/save_sales_cash_transaction', :to => 'payments#save_sales_cash_transaction'
    post '/delete_sales_cash_transaction', :to => 'payments#delete_sales_cash_transaction'

    #SalesCashIncome
    get '/get_sales_cash_income', :to => 'payments#get_sales_cash_income'
    post '/save_sales_cash_income', :to => 'payments#save_sales_cash_income'
    post '/delete_sales_cash_income', :to => 'payments#delete_sales_cash_income'

    #Payment Reports
    get '/sales_reports', :to => 'payments#sales_reports'
    get '/service_providers_report', :to => 'payments#service_providers_report'
    get '/users_report', :to => 'payments#users_report'
    get '/cashiers_report', :to => 'payments#cashiers_report'
    get '/service_providers_report_file', :to => 'payments#service_providers_report_file'

    get '/sales_cash_report_file', :to => 'payments#sales_cash_report_file'
    get '/current_sales_cash_report_file', :to => 'payments#current_sales_cash_report_file'

    get '/get_treatment_price', :to => 'bookings#get_treatment_price'
    get '/payment_summary', :to => 'payments#summary'


    get '/sales_cash_transaction_summary', :to => 'payments#sales_cash_transaction_summary'
    get '/internal_sale_summary', :to => 'payments#internal_sale_summary'
    get '/sales_cash_income_summary', :to => 'payments#sales_cash_income_summary'

    get '/petty_cash_report', :to => 'payments#petty_cash_report'
    #Free plan
    get '/free_plan', :to => 'dashboard#free_plan_landing'

    #Service and categories for location (payments)
    get '/location_categories', :to => 'service_categories#location_categories'
    get '/category_services', :to => 'service_categories#category_services'



    get '/location_users', :to => 'users#location_users'

    get '/get_products_for_payment_or_sale', :to => 'payments#get_products_for_payment_or_sale'
    get '/get_product_categories_for_payment_or_sale', :to => 'payments#get_product_categories_for_payment_or_sale'
    get '/get_product_brands_for_payment_or_sale', :to => 'payments#get_product_brands_for_payment_or_sale'


    #Client charts and files
    get '/get_attribute_categories', :to => 'attributes#get_attribute_categories'
    get '/attribute_edit_form', :to => 'attributes#edit_form'
    get '/get_company_files', :to => 'companies#files'
    post '/create_company_folder', :to => 'companies#create_folder'
    post '/upload_company_file', :to => 'companies#upload_file'
    post '/rename_company_folder', :to => 'companies#rename_folder'
    post '/delete_company_folder', :to => 'companies#delete_folder'
    post '/move_company_file', :to => 'companies#move_file'
    post '/change_company_file', :to => 'companies#edit_file'

    post '/upload_client_file', :to => 'clients#upload_file'
    post '/create_client_folder', :to => 'clients#create_folder'
    get '/get_client_files', :to => 'clients#files'
    post '/rename_client_folder', :to => 'clients#rename_folder'
    post '/delete_client_folder', :to => 'clients#delete_folder'
    post '/move_client_file', :to => 'clients#move_file'
    post '/change_client_file', :to => 'clients#edit_file'

    get '/company_clients_base', :to => 'companies#generate_clients_base'
    get '/client_bookings_content', :to => 'clients#bookings_content'

    get '/billing_info_form', :to => 'billing_infos#super_admin_form'
    post '/billing_info_save', :to => 'billing_infos#super_admin_create'


  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do

      resources :locations, only: [:index, :show]
      get 'locations_search', to: 'locations#search'
      post 'locations/:id/favorite', to: 'locations#favorite'

      resources :services, only: [:show]
      get 'services/:id/service_providers', to: 'services#service_providers'

      get 'service_providers/:id/available_hours', to: 'service_providers#available_hours'
      get 'service_providers/:id/available_days', to: 'service_providers#available_days'

      post 'users/session', to: 'users#login'
      post 'users/registration', to: 'users#create'
      put 'users/me', to: 'users#edit'
      get 'users/me', to: 'users#mobile_user'
      get 'users/bookings', to: 'users#bookings'
      get 'users/favorites', to: 'users#favorites'
      get 'users/searches', to: 'users#searches'
      post 'users/oauth', to: 'users#oauth'

      resources :economic_sectors

      post 'bookings', to: 'bookings#book_service'
      get 'bookings/:id', to: 'bookings#show'
      put 'bookings/:id', to: 'bookings#edit_booking'
      delete 'bookings/:id', to: 'bookings#destroy'

      get 'promotions', to: 'promotions#index'
      get 'promotions/:id', to: 'promotions#show'
    end
    namespace :v2 do

      resources :locations, only: [:index, :show]
      get 'locations_search', to: 'locations#search'
      post 'locations/:id/favorite', to: 'locations#favorite'

      resources :services, only: [:show]
      get 'services/:id/service_providers', to: 'services#service_providers'

      get 'service_providers/:id/available_hours', to: 'service_providers#available_hours'
      get 'service_providers/:id/available_days', to: 'service_providers#available_days'

      post 'users/session', to: 'users#login'
      post 'users/registration', to: 'users#create'
      put 'users/me', to: 'users#edit'
      get 'users/me', to: 'users#mobile_user'
      get 'users/bookings', to: 'users#bookings'
      get 'users/favorites', to: 'users#favorites'
      get 'users/searches', to: 'users#searches'
      post 'users/oauth', to: 'users#oauth'

      resources :economic_sectors

      post 'bookings', to: 'bookings#book_service'
      get 'bookings/:id', to: 'bookings#show'
      put 'bookings/:id', to: 'bookings#edit_booking'
      delete 'bookings/:id', to: 'bookings#destroy'

      get 'promotions', to: 'promotions#index'
      get 'promotions/:id', to: 'promotions#show'
    end
  end

  namespace :api_views, defaults: {format: 'json'} do
    namespace :marketplace do
      namespace :v1 do
        get 'companies_preview', to: 'companies#preview'

        get 'categories', to: 'economic_sectors#categories'

        get 'countries/:id', to: 'countries#show'

        get 'promotions', to: 'promotions#index'
        get 'promotions/index/preview', to: 'promotions#preview'
        get 'promotions/:id', to: 'promotions#show'

        get 'locations', to: 'locations#search'
        get 'locations/:id', to: 'locations#show'

        get 'service_providers/available_hours', to: 'service_providers#available_hours'
        get 'service_providers/available_days', to: 'service_providers#available_days'
        get 'service_providers/available_promo_days', to: 'service_providers#available_promo_days'

        post 'users/session', to: 'users#login'
        post 'users/registration', to: 'users#create'
        put 'users/me', to: 'users#edit'
        get 'users/me', to: 'users#api_user'
        get 'users/bookings', to: 'users#bookings'
        get 'users/favorites', to: 'users#favorites'
        # get 'users/searches', to: 'users#searches'
        post 'newsletter', to: 'users#newsletter'
        post 'users/oauth', to: 'users#oauth'
        # options 'users/oauth', to: 'users#oauth'
        get 'users/oauth_login_link', to: 'users#oauth_login_link'

        post 'bookings', to: 'bookings#book_service'
        get 'bookings/:id', to: 'bookings#show'
        get 'bookings_group', to: 'bookings#show_group'
        put 'bookings/:id', to: 'bookings#edit_booking'
        delete 'bookings/:id', to: 'bookings#destroy'
        delete 'bookings_all/:id', to: 'bookings#cancel_all'
        post 'bookings_confirm', to: 'bookings#confirm'
        post 'bookings_confirm_all', to: 'bookings#confirm_all'

      end
    end
  end

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
