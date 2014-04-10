Agendapro::Application.routes.draw do

  get "users/index"
  require 'subdomain'

  # Mandrill
  get 'mandrill/confirm_unsubscribe', :as => 'unsubscribe'
  post "mandrill/unsubscribe"
  get "mandrill/resuscribe"

  devise_for :users, controllers: {registrations: 'registrations'}
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

  namespace :admin do 
    get '', :to => 'dashboard#index', :as => '/'
    resources :users 
  end

  # Quick Add
  get '/quick_add', :to => 'quick_add#quick_add', :as => 'quick_add'
  get '/quick_add/service_provider', :to => 'quick_add#service_provider', :as => 'quick_add_service_provider'
    # Validation
  post '/quick_add/location_valid', :to => 'quick_add#location_valid'
  post '/quick_add/services_valid', :to => 'quick_add#services_valid'
  post '/quick_add/service_provider_valid', :to => 'quick_add#service_provider_valid'
    # POST
  post '/quick_add/location', :to => 'quick_add#create_location'
  post '/quick_add/services', :to => 'quick_add#create_services'
  post '/quick_add/service_provider', :to => 'quick_add#create_service_provider'

  get '/dashboard', :to => 'dashboard#index', :as => 'dashboard'
  get '/reports', :to => 'reports#index', :as => 'reports'
  get '/clients', :to => 'clients#index', :as => 'clients'
  get '/select_plan', :to => 'plans#select_plan', :as => 'select_plan'
  get '/get_direction', :to => 'districts#get_direction'
  get '/time_booking_edit', :to => 'company_settings#time_booking_edit', :as => 'time_booking'
  post '/send_mail_client', :to => 'clients#send_mail'

  get '/clients_suggestion', :to => 'clients#suggestion'
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
  get "/contact", :to => 'home#contact', :as => 'contact'
  post "/pcontact", :to => 'home#post_contact'

  # Search
  get "searchs/index"
  get '/search', :to => "searchs#search"
  get '/get_districts', :to => 'districts#get_districts'
  get '/get_district', :to => 'districts#get_district'
  get '/district_by_name', :to => 'districts#get_district_by_name'

  # Workflow
  # Workflow - overview
  get '/schedule', :to => 'location_times#schedule_local'
  get '/local', :to => 'locations#location_data'
  # wrokflow - wizard
  get '/workflow', :to => 'companies#workflow', :as => 'workflow'
  get '/local_services', :to => 'service_providers#location_services'
  get '/local_providers', :to => 'service_providers#location_providers'
  get '/providers_services', :to => 'services#get_providers'
  get '/location_time', :to => 'locations#location_time'
  get '/get_booking', :to => 'bookings#get_booking'
  get '/get_booking_info', :to => 'bookings#get_booking_info'
  post "/book", :to => 'bookings#book_service'
  get '/category_name', :to => 'service_categories#get_category_name'
  get '/get_available_time', :to => 'locations#get_available_time'

  # Fullcalendar
  get '/service', :to => 'services#service_data'  # Fullcalendar
  get '/services_list', :to => 'services#services_data'  # Fullcalendar
  get '/provider_time', :to => 'service_providers#provider_time'  # Fullcalendar
  get '/booking', :to => 'bookings#provider_booking'  # Fullcalendar

  get '/edit_booking', :to => 'bookings#edit_booking', :as => 'booking_edit'
  post '/edited_booking', :to => 'bookings#edit_booking_post'
  get '/cancel_booking', :to => 'bookings#cancel_booking', :as => 'booking_cancel'
  post '/cancel_booking', :to => 'bookings#cancel_booking'

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
