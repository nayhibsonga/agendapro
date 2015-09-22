class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    alias_action :index, :show, :to => :read
    
    #alias_action :workflow, :to => :destroy
    #alias_action :workflow, :to => :update
    #alias_action :workflow, :to => :create

    company_abilities = [User, Location, ServiceProvider, Service, CompanySetting, ServiceCategory, Client, BillingInfo, ProviderGroup]


    user ||= User.new # guest user (not logged in)

    can :new, :all

    can :read, User, :id => user.id
    can :update, User, :id => user.id
    can :destroy, User, :id => user.id

    # Permiso para ver el horario de los locales
    can :schedule_local, LocationTime

    # Home
    can :view_plans, Plan

    # Workflow
    can :overview, Company
    can :workflow, Company
    can :location_data, Location
    can :location_districts, Location
    can :service_data, Service
    can :services_data, Service
    can :get_providers, Service
    can :provider_booking, Booking
    can :book_service, Booking
    can :location_services, Service
    can :location_categorized_services, Service
    can :location_providers, ServiceProvider
    can :provider_time, ServiceProvider
    can :location_time, Location
    can :get_available_time, Location
    can :company_service_categories, ServiceCategory
    can :check_user_cross_bookings, Booking
    can :select_hour, Company
    can :select_promo_hour, Company
    can :select_session_hour, Company
    can :user_data, Company
    can :client_loader, Client
    can :available_hours_week_html, ServiceProvider

    can :edit_booking, Booking
    can :edit_booking_post, Booking
    can :cancel_booking, Booking
    can :confirm_booking, Booking
    can :confirm_all_bookings, Booking
    can :confirm_error, Booking
    can :confirm_success, Booking

    # Search
    can :get_districts, District
    can :get_input_districts, District
    can :get_district, District
    can :get_district_by_name, District

    can :get_direction, District

    can :agenda, User, :id => user.id
    can :get_session_bookings, User
    can :get_session_summary, User
    can :delete_session_booking, Booking
    can :validate_session_booking, Booking
    can :validate_session_form, Booking
    can :session_booking_detail, Booking
    can :book_session_form, Booking
    can :update_book_session, Booking
    can :sessions_calendar, Booking

    can :pdf, ServiceProvider

    # Singup Validate
    can :check_user_email, User
    can :check_company_web_address, Company

    
    can :get_promotions_popover, Service
    can :promotion_hours, Booking
    can :show_time_promo, Service
    can :show_last_minute_promo, Service
    can :last_minute_hours, Service


    if user.role_id == Role.find_by_name("Super Admin").id

        can :manage, :all
    
    elsif user.role_id == Role.find_by_name("Usuario Registrado").id

        can :add_company, Company
        can :create, Company  

    elsif user.role_id == Role.find_by_name("Administrador General").id

        can :select_plan, Plan

        can :add_company, Company

        can :get_booking, Booking, :service_provider => { :company_id => user.company_id }
        can :get_booking_info, Booking, :service_provider => { :company_id => user.company_id }
        can :get_booking_for_payment, Booking, :service_provider => { :company_id => user.company_id }
        can :available_providers, ServiceProvider
        can :provider_breaks, ProviderBreak
        can :get_provider_break, ProviderBreak
        can :create_provider_break, ProviderBreak
        can :update_provider_break, ProviderBreak
        can :destroy_provider_break, ProviderBreak
        can :update_repeat_break, ProviderBreak
        can :destroy_repeat_break, ProviderBreak

        can :read, Company, :id => user.company_id
        can :destroy, Company, :id => user.company_id
        can :create, Company, :id => user.company_id
        can :update, Company, :id => user.company_id

        can :location_products, Location, :company_id => user.company_id
        can :get_staff_by_code, StaffCode, :company_id => user.company_id
        can :create_new_payment, Payment, :company_id => user.company_id
        can :alarm_form, Product, :company_id => user.company_id
        can :inventory, Location, :company_id => user.company_id
        can :set_alarm, Product, :company_id => user.company_id
        can :inventory, Company, :company_id => user.company_id
        can :stock_alarm_form, Company, :company_id => user.company_id
        can :stock_alarm_form, Location, :company_id => user.company_id
        can :save_stock_alarm, Location, :company_id => user.company_id

        # can :read, CompanyFromEmail
        # can :destroy, CompanyFromEmail
        # can :create, CompanyFromEmail
        # can :update, CompanyFromEmail

        # can :read, StaffCode
        # can :destroy, StaffCode
        # can :create, StaffCode
        # can :update, StaffCode

        company_abilities.each do |c|
            can :read, c, :company_id => user.company_id
            can :destroy, c, :company_id => user.company_id
            can :create, c, :company_id => user.company_id
            can :update, c, :company_id => user.company_id
        end

        can :inactive_index, Location, :company_id => user.company_id
        can :activate, Location, :company_id => user.company_id
        can :deactivate, Location, :company_id => user.company_id

        can :inactive_index, Service, :company_id => user.company_id
        can :activate, Service, :company_id => user.company_id
        can :deactivate, Service, :company_id => user.company_id

        can :inactive_index, ServiceProvider, :company_id => user.company_id
        can :activate, ServiceProvider, :company_id => user.company_id
        can :deactivate, ServiceProvider, :company_id => user.company_id

        can :read, LocationTime, :location => { :company_id => user.company_id }
        can :destroy, LocationTime, :location => { :company_id => user.company_id }
        can :create, LocationTime, :location => { :company_id => user.company_id }
        can :update, LocationTime, :location => { :company_id => user.company_id }
                
        can :read, ProviderTime, :service_provider => { :company_id => user.company_id }
        can :destroy, ProviderTime, :service_provider => { :company_id => user.company_id }
        can :create, ProviderTime, :service_provider => { :company_id => user.company_id }
        can :update, ProviderTime, :service_provider => { :company_id => user.company_id }

        can :read, Booking, :service_provider => { :company_id => user.company_id }
        can :destroy, Booking, :service_provider => { :company_id => user.company_id }
        can :create, Booking, :service_provider => { :company_id => user.company_id }
        can :update, Booking, :service_provider => { :company_id => user.company_id }

        can :read, Resource, :company_id => user.company_id
        can :destroy, Resource, :company_id => user.company_id
        can :create, Resource, :company_id => user.company_id
        can :update, Resource, :company_id => user.company_id

        can :read, ResourceCategory, :company_id => user.company_id
        can :destroy, ResourceCategory, :company_id => user.company_id
        can :create, ResourceCategory, :company_id => user.company_id
        can :update, ResourceCategory, :company_id => user.company_id

        can :read, Product, :company_id => user.company_id
        can :destroy, Product, :company_id => user.company_id
        can :create, Product, :company_id => user.company_id
        can :update, Product, :company_id => user.company_id
        can :edit, Product, :company_id => user.company_id

        can :read, ProductCategory, :company_id => user.company_id
        can :destroy, ProductCategory, :company_id => user.company_id
        can :create, ProductCategory, :company_id => user.company_id
        can :update, ProductCategory, :company_id => user.company_id

        can :read, ProductBrand, :company_id => user.company_id
        can :destroy, ProductBrand, :company_id => user.company_id
        can :create, ProductBrand, :company_id => user.company_id
        can :update, ProductBrand, :company_id => user.company_id

        can :read, ProductDisplay, :company_id => user.company_id
        can :destroy, ProductDisplay, :company_id => user.company_id
        can :create, ProductDisplay, :company_id => user.company_id
        can :update, ProductDisplay, :company_id => user.company_id

        can :provider_service, ServiceProvider

        can :get_link, Company

        can :history, Client, :company_id => user.company_id
        can :name_suggestion, Client
        can :suggestion, Client
        can :rut_suggestion, Client
        can :bookings_history, Client
        can :check_sessions, Client

        can :booking_payment, Payment
        can :load_payment, Payment
        can :past_bookings, Payment
        can :past_sessions, Payment
        can :client_bookings, Payment
        can :client_sessions, Payment
        can :index_content, Payment
        can :read, Payment, :company_id => user.company_id
        can :destroy, Payment, :company_id => user.company_id
        can :create, Payment, :company_id => user.company_id
        can :update, Payment, :company_id => user.company_id

        can :create_comment, Client
        can :update_comment, Client
        can :destroy_comment, Client

        can :compose_mail, Client, :company_id => user.company_id
        can :send_mail, Client, :company_id => user.company_id
        can :import, Client

        can :import, Product

        can :change_categories_order, ServiceCategory
        can :change_services_order, Service
        can :change_location_order, Location
        can :change_providers_order, ServiceProvider
        can :change_groups_order, ProviderGroup

        can :country_regions, Region
        can :region_cities, City
        can :city_districs, District

        can :delete_facebook_pages, CompanySetting

        can :set_promotions, Service
        can :set_service_promo_times, Service
        can :read, CompanyPaymentMethod, :company_id => user.company_id
        can :create, CompanyPaymentMethod, :company_id => user.company_id
        can :update, CompanyPaymentMethod, :company_id => user.company_id
        can :destroy, CompanyPaymentMethod, :company_id => user.company_id
        can :activate, CompanyPaymentMethod, :company_id => user.company_id
        can :deactivate, CompanyPaymentMethod, :company_id => user.company_id

        can :read, Deal, :company_id => user.company_id
        can :create, Deal, :company_id => user.company_id
        can :update, Deal, :company_id => user.company_id

    elsif user.role_id == Role.find_by_name("Administrador Local").id

        can :get_booking, Booking, :location_id => user.locations.pluck(:id)
        can :get_booking_info, Booking, :location_id => user.locations.pluck(:id)
        can :available_providers, ServiceProvider, :location_id => user.locations.pluck(:id)
        can :provider_breaks, ProviderBreak
        can :get_provider_break, ProviderBreak
        can :create_provider_break, ProviderBreak
        can :update_provider_break, ProviderBreak
        can :destroy_provider_break, ProviderBreak

        # can :read, StaffCode, :company_id => user.company_id
        can :read, BookingHistory, :company_id => user.company_id

        can :read, Service, :company_id => user.company_id
        can :create, Service, :company_id => user.company_id
        can :update, Service, :company_id => user.company_id

        can :read, ServiceCategory, :company_id => user.company_id
        can :create, ServiceCategory, :company_id => user.company_id
        can :update, ServiceCategory, :company_id => user.company_id

        can :read, ProviderGroup, :company_id => user.company_id
        can :create, ProviderGroup, :company_id => user.company_id
        can :update, ProviderGroup, :company_id => user.company_id

        can :history, Client, :company_id => user.company_id
        can :read, Client, :company_id => user.company_id
        can :create, Client, :company_id => user.company_id
        can :update, Client, :company_id => user.company_id
        can :destroy, Client, :company_id => user.company_id

        can :read, Resource, :company_id => user.company_id
        can :create, Resource, :company_id => user.company_id
        can :update, Resource, :company_id => user.company_id

        can :read, ResourceCategory, :company_id => user.company_id
        can :destroy, ResourceCategory, :company_id => user.company_id
        can :create, ResourceCategory, :company_id => user.company_id
        can :update, ResourceCategory, :company_id => user.company_id

        can :read, Product, :company_id => user.company_id
        can :destroy, Product, :company_id => user.company_id
        can :create, Product, :company_id => user.company_id
        can :update, Product, :company_id => user.company_id

        can :location_products, Location, :company_id => user.company_id
        can :get_staff_by_code, StaffCode, :company_id => user.company_id
        can :create_new_payment, Payment, :company_id => user.company_id
        can :alarm_form, Product, :company_id => user.company_id
        can :inventory, Location, :company_id => user.company_id
        can :set_alarm, Product, :company_id => user.company_id
        #can :inventory, Company, :company_id => user.company_id
        can :stock_alarm_form, Location, :company_id => user.company_id
        can :save_stock_alarm, Location, :company_id => user.company_id

        can :read, ProductCategory, :company_id => user.company_id
        can :destroy, ProductCategory, :company_id => user.company_id
        can :create, ProductCategory, :company_id => user.company_id
        can :update, ProductCategory, :company_id => user.company_id

        can :read, ProductBrand, :company_id => user.company_id
        can :destroy, ProductBrand, :company_id => user.company_id
        can :create, ProductBrand, :company_id => user.company_id
        can :update, ProductBrand, :company_id => user.company_id

        can :read, ProductDisplay, :company_id => user.company_id
        can :destroy, ProductDisplay, :company_id => user.company_id
        can :create, ProductDisplay, :company_id => user.company_id
        can :update, ProductDisplay, :company_id => user.company_id

        @roles = Role.where(:name => ["Recepcionista","Staff"]).pluck(:id)

        can :read, User, :location_id => user.locations, :role_id => @roles
        can :destroy, User, :location_id => user.locations, :role_id => @roles
        can :create, User, :location_id => user.locations, :role_id => @roles
        can :update, User, :location_id => user.locations, :role_id => @roles

        can :read, ServiceProvider, :location_id => user.locations.pluck(:id)
        can :destroy, ServiceProvider, :location_id => user.locations.pluck(:id)
        can :create, ServiceProvider, :location_id => user.locations.pluck(:id)
        can :update, ServiceProvider, :location_id => user.locations.pluck(:id)

        can :inactive_index, Service, :company_id => user.company_id
        can :activate, Service, :company_id => user.company_id
        can :deactivate, Service, :company_id => user.company_id

        can :inactive_index, ServiceProvider, :location_id => user.locations.pluck(:id)
        can :activate, ServiceProvider, :location_id =>  user.locations.pluck(:id)
        can :deactivate, ServiceProvider, :location_id => user.locations.pluck(:id)

        can :read, Location, :id => user.locations.pluck(:id)
        can :update, Location, :id => user.locations.pluck(:id)

        can :read, LocationTime, :location_id => user.locations.pluck(:id)
        can :destroy, LocationTime, :location_id => user.locations.pluck(:id)
        can :create, LocationTime, :location_id => user.locations.pluck(:id)
        can :update, LocationTime, :location_id => user.locations.pluck(:id)

        can :read, ProviderTime, :service_provider => { :location_id => user.locations.pluck(:id) }
        can :destroy, ProviderTime, :service_provider => { :location_id => user.locations.pluck(:id) }
        can :create, ProviderTime, :service_provider => { :location_id => user.locations.pluck(:id) }
        can :update, ProviderTime, :service_provider => { :location_id => user.locations.pluck(:id) }

        can :read, Booking, :location_id => user.locations.pluck(:id)
        can :destroy, Booking, :location_id => user.locations.pluck(:id) 
        can :create, Booking, :location_id => user.locations.pluck(:id)
        can :update, Booking, :location_id => user.locations.pluck(:id)

        can :provider_service, ServiceProvider
        can :name_suggestion, Client
        can :suggestion, Client
        can :rut_suggestion, Client
        can :bookings_history, Client
        can :check_sessions, Client
        
        can :create_comment, Client, :company_id => user.company_id
        can :update_comment, Client, :company_id => user.company_id
        can :destroy_comment, Client, :company_id => user.company_id

        can :booking_payment, Payment
        can :load_payment, Payment
        can :past_bookings, Payment
        can :past_sessions, Payment
        can :client_bookings, Payment
        can :client_sessions, Payment
        can :index_content, Payment
        can :read, Payment, :company_id => user.company_id
        can :destroy, Payment, :company_id => user.company_id
        can :create, Payment, :company_id => user.company_id
        can :update, Payment, :company_id => user.company_id
        
        can :compose_mail, Client, :company_id => user.company_id
        can :send_mail, Client, :company_id => user.company_id
        can :import, Client

        can :import, Product

        can :change_categories_order, ServiceCategory
        can :change_services_order, Service
        can :change_location_order, Location
        can :change_providers_order, ServiceProvider
        can :change_groups_order, ProviderGroup

        can :country_regions, Region
        can :region_cities, City
        can :city_districs, District

    elsif user.role_id == Role.find_by_name("Recepcionista").id

        can :get_booking, Booking, :location_id => user.locations.pluck(:id)
        can :get_booking_info, Booking, :location_id => user.locations.pluck(:id)
        can :available_providers, ServiceProvider, :location_id => user.locations.pluck(:id)
        can :provider_breaks, ProviderBreak
        can :get_provider_break, ProviderBreak
        can :create_provider_break, ProviderBreak
        can :update_provider_break, ProviderBreak
        can :destroy_provider_break, ProviderBreak

        can :read, Service, :company_id => user.company_id

        can :read, ServiceProvider, :location_id => user.locations.pluck(:id)

        can :read, Location, :id => user.locations
        
        can :read, ProviderTime, :service_provider => { :location_id => user.locations.pluck(:id) }

        can :history, Client, :company_id => user.company_id
        can :read, Client, :company_id => user.company_id
        can :create, Client, :company_id => user.company_id
        can :update, Client, :company_id => user.company_id

        can :read, Booking, :location_id => user.locations.pluck(:id)
        can :destroy, Booking, :location_id => user.locations.pluck(:id)
        can :create, Booking, :location_id => user.locations.pluck(:id)
        can :update, Booking, :location_id => user.locations.pluck(:id)

        can :name_suggestion, Client
        can :suggestion, Client
        can :rut_suggestion, Client
        can :provider_service, ServiceProvider
        can :bookings_history, Client
        can :check_sessions, Client

        can :booking_payment, Payment
        can :load_payment, Payment
        can :past_bookings, Payment
        can :past_sessions, Payment
        can :client_bookings, Payment
        can :client_sessions, Payment
        can :read, Payment, :company_id => user.company_id
        can :destroy, Payment, :company_id => user.company_id
        can :create, Payment, :company_id => user.company_id
        can :update, Payment, :company_id => user.company_id
        
        can :create_comment, Client, :company_id => user.company_id
        can :update_comment, Client, :company_id => user.company_id
        can :destroy_comment, Client, :company_id => user.company_id

        can :compose_mail, Client, :company_id => user.company_id
        can :send_mail, Client, :company_id => user.company_id
        can :import, Client

        can :location_products, Location, :company_id => user.company_id
        can :get_staff_by_code, StaffCode, :company_id => user.company_id
        can :create_new_payment, Payment, :company_id => user.company_id

    elsif user.role_id == Role.find_by_name("Staff").id
        
        can :get_booking, Booking, :service_provider_id => user.service_providers.pluck(:id)

        can :read, ServiceProvider, :id => user.service_providers.pluck(:id)

        can :read, Location, :company_id => user.company_id

        can :read, LocationTime, :location => {:company_id => user.company_id }

        can :read, ProviderTime, :service_provider => user.service_providers.pluck(:id)

        can :read, Service, :company_id => user.company_id

        can :read, Booking, :service_provider_id => user.service_providers.pluck(:id)
        can :destroy, Booking, :service_provider_id => user.service_providers.pluck(:id)
        can :create, Booking, :service_provider_id => user.service_providers.pluck(:id)
        can :update, Booking, :service_provider_id => user.service_providers.pluck(:id)

        can :provider_breaks, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        can :get_provider_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        can :create_provider_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        can :update_provider_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        can :destroy_provider_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        
        can :name_suggestion, Client
        can :suggestion, Client
        can :rut_suggestion, Client
        can :provider_service, ServiceProvider
        can :bookings_history, Client
        can :check_sessions, Client

        can :booking_payment, Payment
        can :load_payment, Payment
        can :past_bookings, Payment
        can :past_sessions, Payment
        can :client_bookings, Payment
        can :client_sessions, Payment
        can :read, Payment, :company_id => user.company_id
        can :destroy, Payment, :company_id => user.company_id
        can :create, Payment, :company_id => user.company_id
        can :update, Payment, :company_id => user.company_id

    elsif user.role_id == Role.find_by_name("Staff (sin edición)").id

        can :read, ServiceProvider, :id => user.service_providers.pluck(:id)

        can :read, Location, :company_id => user.company_id

        can :read, LocationTime, :location => {:company_id => user.company_id }

        can :read, ProviderTime, :service_provider => user.service_providers.pluck(:id)

        can :read, Service, :company_id => user.company_id

        # can :read, Booking, :service_provider_id => user.service_providers.pluck(:id)
        # can :destroy, Booking, :service_provider_id => user.service_providers.pluck(:id)
        # can :create, Booking, :service_provider_id => user.service_providers.pluck(:id)
        # can :update, Booking, :service_provider_id => user.service_providers.pluck(:id)

        # can :provider_breaks, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        # can :get_provider_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        # can :create_provider_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        # can :update_provider_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        # can :destroy_provider_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        
        # can :name_suggestion, Client
        # can :suggestion, Client
        # can :rut_suggestion, Client
        # can :provider_service, ServiceProvider
    end

  end
end
