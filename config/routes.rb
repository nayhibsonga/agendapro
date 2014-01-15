Agendapro::Application.routes.draw do

  get "users/index"
  require 'subdomain'

  devise_for :users, controllers: {registrations: 'registrations'}
  resources :countries
  resources :regions
  resources :cities
  resources :districts

  resources :tags
  resources :statuses
  resources :economic_sectors
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

  get '/quick_add/location', :to => 'quick_add#location', :as => 'quick_add_location'
  get '/quick_add/services', :to => 'quick_add#services', :as => 'quick_add_services'
  get '/quick_add/service_provider', :to => 'quick_add#service_provider', :as => 'quick_add_service_provider'
  put '/quick_add/location', :to => 'quick_add#create_location', :as => 'quick_add_create_location'
  put '/quick_add/services', :to => 'quick_add#create_services', :as => 'quick_add_create_services'
  put '/quick_add/service_provider', :to => 'quick_add#create_service_provider', :as => 'quick_add_create_service_provider'

  get '/dashboard', :to => 'dashboard#index', :as => 'dashboard'
  get '/reports', :to => 'reports#index', :as => 'reports'
  get '/clients', :to => 'clients#index', :as => 'clients'
  get '/select_plan', :to => 'plans#selectplan', :as => 'select_plan'
  get '/get_direction', :to => 'districts#getDirection'

  get "/home", :to => 'home#index', :as => 'home'
  get "/features", :to => 'home#features', :as => 'features'
  get "/view_plans", :to => 'plans#viewplans', :as => 'view_plans'
  get "/about_us", :to => 'home#about_us',  :as => 'aboutus'
  get "/contact", :to => 'home#contact', :as => 'contact'
  post "/pcontact", :to => 'home#post_contact'

  # Search
  get "searchs/index"
  get '/search', :to => "searchs#search"
  get 'get_countries', :to => 'countries#getCountries'
  get '/get_regions', :to => 'regions#getRegions'
  get '/get_cities', :to => 'cities#getCities'
  get '/get_districts', :to => 'districts#getDistricts'
  get '/get_district', :to => 'districts#getDistrict'

  # Workflow
  # Workflow - overview
  get '/schedule', :to => 'location_times#scheduleLocal'
  get '/local', :to => 'locations#locationData'
  # wrokflow - wizard
  get '/local_services', :to => 'service_providers#locationServices'
  get '/service', :to => 'services#serviceData'
  get '/providers_services', :to => 'services#getProviders'
  get '/provider_time', :to => 'service_providers#providerTime'
  get '/booking', :to => 'bookings#providerBooking'
  post "/book", :to => 'bookings#bookService'
  get '/category_name', :to => 'service_categories#get_category_name'
  
  # Root
  get '/' => 'searchs#index', :constraints => { :subdomain => 'www' }
  get '/' => 'companies#workflow', :constraints => { :subdomain => /.+/ }

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
