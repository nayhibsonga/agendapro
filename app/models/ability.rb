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

    company_abilities = [User, Location, ServiceProvider, Service, Bundle, CompanySetting, ServiceCategory, Client, BillingInfo, ProviderGroup]


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
    can :location_categories, ServiceCategory
    can :category_services, ServiceCategory
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
    can :mobile_hours, Company
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
    can :user_delete_treatment, Booking

    can :pdf, ServiceProvider
    can :default_time, ServiceProvider

    # Singup Validate
    can :check_user_email, User
    can :check_company_web_address, Company


    can :get_promotions_popover, Service
    can :promotion_hours, Booking
    can :available_hours, Booking
    can :show_time_promo, Service
    can :show_last_minute_promo, Service
    can :last_minute_hours, Service
    can :show_treatment_promo, Service
    can :treatment_promo_hours, Service
    can :get_treatment_price, Booking
    can :hours_test, Booking

    if user.role_id == Role.find_by_name("Super Admin").id

        can :manage, :all

    elsif user.role_id == Role.find_by_name("Usuario Registrado").id

        can :add_company, Company
        can :create, Company

    elsif user.role_id == Role.find_by_name("Administrador General").id

        can :summary, Booking, :company_id => user.company_id
        can :chart, Booking, :company_id => user.company_id
        can :print, Client, :company_id => user.company_id
        can :print, Chart, :company_id => user.company_id

        can :bookings, Chart, :company_id => user.company_id
        can :summary, Chart, :company_id => user.company_id
        can :read, Chart, :company_id => user.company_id
        can :destroy, Chart, :company_id => user.company_id
        can :create, Chart, :company_id => user.company_id
        can :update, Chart, :company_id => user.company_id
        can :edit_form, Chart, :company_id => user.company_id

        can :merge, Client, :company_id => user.company_id

        can :get_custom_attributes, Client, :company_id => user.company_id

        can :payments, Client, :company_id => user.company_id
        can :payments_content, Client, :company_id => user.company_id
        can :emails, Client, :company_id => user.company_id
        can :emails_content, Client, :company_id => user.company_id
        can :last_payments, Client, :company_id => user.company_id
        can :charts, Client, :company_id => user.company_id
        can :charts_content, Client, :company_id => user.company_id

        can :stock_change, Product, :company_id => user.company_id
        can :update_stock, Product, :company_id => user.company_id

        can :delete_treatment, Booking, :company_id => user.company_id
        can :delete_client_treatment, Booking, :company_id => user.company_id
        can :get_treatment_info, Booking, :company_id => user.company_id
        can :get_email_logs, Booking, :company_id => user.company_id

        can :new_filter_form, CustomFilter, :company_id => user.company_id
        can :edit_filter_form, CustomFilter, :company_id => user.company_id
        can :client_base_pdf, Client, :company_id => user.company_id

        can :select_default_plan, Company, :company_id => user.company_id

        can :rearrange, Attribute, :company_id => user.company_id
        can :rearrange, AttributeGroup, :company_id => user.company_id
        can :rearrange, ChartField, :company_id => user.company_id
        can :rearrange, ChartGroup, :company_id => user.company_id

        can :select_plan, Plan
        can :use_email_templates, Client #FIXME
        can :mail_editor, Client, :company_id => user.company_id #FIXME
        can :upload_content, Client
        can :save_content, Client
        can :send_content, Client

        can :add_company, Company

        can :location_users, User, :company_id => user.company_id

        can :get_booking, Booking, :service_provider => { :company_id => user.company_id }
        can :get_booking_info, Booking, :service_provider => { :company_id => user.company_id }
        can :get_booking_for_payment, Booking, :company_id => user.company_id
        can :get_session_booking_for_payment, Booking, :company_id => user.company_id
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

        can :locations_stats_excel, Product, :company_id => user.company_id
        can :logs_history_excel, Product, :company_id => user.company_id
        can :logs_history, Product, :company_id => user.company_id
        can :products, ProductCategory, :company_id => user.company_id
        can :history, Product, :company_id => user.company_id
        can :seller_history, Product, :company_id => user.company_id
        can :product_history, Product, :company_id => user.company_id
        can :stats, Product, :company_id => user.company_id
        can :locations_stats, Product, :company_id => user.company_id
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
        can :sellers, Location, :company_id => user.company_id
        can :get_by_code, Cashier, :company_id => user.company_id
        can :get_by_code, EmployeeCode, :company_id => user.company_id
        can :check_staff_code, EmployeeCode, :company_id => user.company_id
        can :receipt_pdf, Payment, :company_id => user.company_id
        can :payment_pdf, Payment, :company_id => user.company_id
        can :send_receipts_email, Payment, :company_id => user.company_id
        can :get_receipts, Payment, :company_id => user.company_id
        can :get_intro_info, Payment, :company_id => user.company_id
        can :save_intro_info, Payment, :company_id => user.company_id
        can :update_payment, Payment, :company_id => user.company_id
        can :check_booking_payment, Payment, :company_id => user.company_id
        can :get_formatted_booking, Payment, :company_id => user.company_id
        can :delete_payment, Payment, :company_id => user.company_id

        can :summary, Payment, :company_id => user.company_id
        can :internal_sale_summary, Payment, :company_id => user.company_id

        can :sales_cash_transaction_summary, Payment, :company_id => user.company_id
        can :sales_cash_income_summary, Payment, :company_id => user.company_id

        can :commissions, Payment, :company_id => user.company_id

        can :provider_commissions, Payment, :company_id => user.company_id
        can :service_commissions, Payment, :company_id => user.company_id
        can :set_commissions, Payment, :company_id => user.company_id
        can :set_default_commission, Payment, :company_id => user.company_id
        can :set_provider_default_commissions, Payment, :company_id => user.company_id
        can :commissions_content, Payment, :company_id => user.company_id

        #Petty Cash

        can :petty_cash, Payment, :company_id => user.company_id
        can :petty_transactions, Payment, :company_id => user.company_id
        can :petty_transaction, Payment, :company_id => user.company_id
        can :add_petty_transaction, Payment, :company_id => user.company_id
        can :open_close_petty_cash, Payment, :company_id => user.company_id
        can :delete_petty_transaction, Payment, :company_id => user.company_id
        can :set_petty_cash_close_schedule, Payment, :company_id => user.company_id

        #Sales Cash

        can :sales_cash, Payment, :company_id => user.company_id
        can :sales_cash_content, Payment, :company_id => user.company_id
        can :get_sales_cash, Payment, :company_id => user.company_id
        can :save_sales_cash, Payment, :company_id => user.company_id
        can :close_sales_cash, Payment, :company_id => user.company_id

        can :get_sales_cash_transaction, Payment, :company_id => user.company_id
        can :save_sales_cash_transaction, Payment, :company_id => user.company_id
        can :delete_sales_cash_transaction, Payment, :company_id => user.company_id

        can :get_sales_cash_income, Payment, :company_id => user.company_id
        can :save_sales_cash_income, Payment, :company_id => user.company_id
        can :delete_sales_cash_income, Payment, :company_id => user.company_id

        can :sales_cash_report_file, Payment, :company_id => user.company_id
        can :current_sales_cash_report_file, Payment, :company_id => user.company_id

        can :petty_cash_report, Payment, :company_id => user.company_id

        #Sales Reports
        can :sales_reports, Payment, :company_id => user.company_id
        can :service_providers_report, Payment, :company_id => user.company_id
        can :users_report, Payment, :company_id => user.company_id
        can :cashiers_report, Payment, :company_id => user.company_id
        can :service_providers_report_file, Payment, :company_id => user.company_id

        #Internal Sale
        can :save_internal_sale, Payment, :company_id => user.company_id
        can :delete_internal_sale, Payment, :company_id => user.company_id
        can :get_internal_sale, Payment, :company_id => user.company_id
        can :get_product_for_payment_or_sale, Payment, :company_id => user.company_id
        can :get_products_for_payment_or_sale, Payment, :company_id => user.company_id
        can :get_product_brands_for_payment_or_sale, Payment, :company_id => user.company_id
        can :get_product_categories_for_payment_or_sale, Payment, :company_id => user.company_id

        #Surveys
        can :read, SurveyConstruct, :company_id => user.company_id
        can :destroy, SurveyConstruct, :company_id => user.company_id
        can :create, SurveyConstruct, :company_id => user.company_id
        can :update, SurveyConstruct, :company_id => user.company_id
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
        can :bookings_content, Client, :company_id => user.company_id
        can :treatments_content, Client, :company_id => user.company_id

        can :booking_payment, Payment
        can :load_payment, Payment
        can :past_bookings, Payment
        can :past_sessions, Payment
        can :client_bookings, Payment
        can :client_treatments, Payment
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
        can :campaigns_report_content, Client, :company_id => user.company_id
        can :campaign_report_details, Client, :company_id => user.company_id
        can :import, Client
        can :download, Client
        can :file_generation, Client

        can :import, Product
        can :download, Product

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

        can :show, Cashier, :company_id => user.company_id
        can :create, Cashier, :company_id => user.company_id
        can :update, Cashier, :company_id => user.company_id
        can :destroy, Cashier, :company_id => user.company_id
        can :activate, Cashier, :company_id => user.company_id
        can :deactivate, Cashier, :company_id => user.company_id

        can :show, EmployeeCode, :company_id => user.company_id
        can :create, EmployeeCode, :company_id => user.company_id
        can :update, EmployeeCode, :company_id => user.company_id
        can :destroy, EmployeeCode, :company_id => user.company_id
        can :activate, EmployeeCode, :company_id => user.company_id
        can :deactivate, EmployeeCode, :company_id => user.company_id

        can :show, Attribute, :company_id => user.company_id
        can :create, Attribute, :company_id => user.company_id
        can :update, Attribute, :company_id => user.company_id
        can :destroy, Attribute, :company_id => user.company_id
        can :edit_form, Attribute, :company_id => user.company_id

        can :show, AttributeCategory, :company_id => user.company_id
        can :create, AttributeCategory, :company_id => user.company_id
        can :update, AttributeCategory, :company_id => user.company_id
        can :destroy, AttributeCategory, :company_id => user.company_id

        can :show, AttributeGroup, :company_id => user.company_id
        can :create, AttributeGroup, :company_id => user.company_id
        can :update, AttributeGroup, :company_id => user.company_id
        can :destroy, AttributeGroup, :company_id => user.company_id
        can :edit_form, AttributeGroup, :company_id => user.company_id

        can :show, ChartField, :company_id => user.company_id
        can :create, ChartField, :company_id => user.company_id
        can :update, ChartField, :company_id => user.company_id
        can :destroy, ChartField, :company_id => user.company_id
        can :edit_form, ChartField, :company_id => user.company_id

        can :show, ChartCategory, :company_id => user.company_id
        can :create, ChartCategory, :company_id => user.company_id
        can :update, ChartCategory, :company_id => user.company_id
        can :destroy, ChartCategory, :company_id => user.company_id

        can :show, ChartGroup, :company_id => user.company_id
        can :create, ChartGroup, :company_id => user.company_id
        can :update, ChartGroup, :company_id => user.company_id
        can :destroy, ChartGroup, :company_id => user.company_id
        can :edit_form, ChartGroup, :company_id => user.company_id

        can :show, ClientFile, :client => {:company_id => user.company_id}
        can :create, ClientFile, :client => {:company_id => user.company_id}
        can :update, ClientFile, :client => {:company_id => user.company_id}
        can :destroy, ClientFile, :client => {:company_id => user.company_id}

        can :show, CompanyFile, :company_id => user.company_id
        can :create, CompanyFile, :company_id => user.company_id
        can :update, CompanyFile, :company_id => user.company_id
        can :destroy, CompanyFile, :company_id => user.company_id

        can :get_attribute_categories, Attribute, :company_id => user.company_id
        can :get_chart_categories, ChartField, :company_id => user.company_id
        can :update_custom_attributes, Client, :company_id => user.company_id

        can :files, Company, :company_id => user.company_id
        can :upload_file, Company, :company_id => user.company_id
        can :create_folder, Company, :company_id => user.company_id
        can :rename_folder, Company, :company_id => user.company_id
        can :delete_folder, Company, :company_id => user.company_id
        can :move_file, Company, :company_id => user.company_id
        can :edit_file, Company, :company_id => user.company_id

        can :files, Client, :company_id => user.company_id
        can :upload_file, Client, :company_id => user.company_id
        can :create_folder, Client, :company_id => user.company_id
        can :rename_folder, Client, :company_id => user.company_id
        can :delete_folder, Client, :company_id => user.company_id
        can :move_file, Client, :company_id => user.company_id
        can :edit_file, Client, :company_id => user.company_id

        can :generate_clients_base, Company, :company_id => user.company_id

        can :read, Deal, :company_id => user.company_id
        can :create, Deal, :company_id => user.company_id
        can :update, Deal, :company_id => user.company_id

        can :pending_billing_wire_transfers, Company
        can :approved_billing_wire_transfers, Company
        can :show_billing_wire_transfer, Company
        can :approve_billing_wire_transfer, Company
        can :delete_billing_wire_transfer, Company
        can :save_billing_wire_transfer, Plan

        can :read, AppFeed, :company_id => user.company_id
        can :create, AppFeed, :company_id => user.company_id
        can :update, AppFeed, :company_id => user.company_id
        can :destroy, AppFeed, :company_id => user.company_id

    elsif user.role_id == Role.find_by_name("Administrador Local").id

        can :summary, Booking, :company_id => user.company_id
        can :chart, Booking, :company_id => user.company_id
        can :print, Client, :company_id => user.company_id
        can :print, Chart, :company_id => user.company_id

        can :bookings, Chart, :company_id => user.company_id
        can :summary, Chart, :company_id => user.company_id
        can :read, Chart, :company_id => user.company_id
        can :destroy, Chart, :company_id => user.company_id
        can :create, Chart, :company_id => user.company_id
        can :update, Chart, :company_id => user.company_id
        can :edit_form, Chart, :company_id => user.company_id
        can :merge, Client, :company_id => user.company_id

        can :generate_clients_base, Company, :company_id => user.company_id

        can :get_custom_attributes, Client, :company_id => user.company_id

        can :payments, Client, :company_id => user.company_id
        can :payments_content, Client, :company_id => user.company_id
        can :emails, Client, :company_id => user.company_id
        can :emails_content, Client, :company_id => user.company_id
        can :last_payments, Client, :company_id => user.company_id
        can :charts, Client, :company_id => user.company_id
        can :charts_content, Client, :company_id => user.company_id

        can :stock_change, Product, :company_id => user.company_id
        can :update_stock, Product, :company_id => user.company_id

        can :delete_treatment, Booking, :company_id => user.company_id
        can :delete_client_treatment, Booking, :company_id => user.company_id
        can :get_treatment_info, Booking, :company_id => user.company_id
        can :get_email_logs, Booking, :company_id => user.company_id

        can :rearrange, Attribute, :company_id => user.company_id
        can :rearrange, AttributeGroup, :company_id => user.company_id
        can :rearrange, ChartField, :company_id => user.company_id
        can :rearrange, ChartGroup, :company_id => user.company_id

        can :upload_file, Client

        can :location_users, User, :company_id => user.company_id

        can :get_booking_for_payment, Booking, :company_id => user.company_id
        can :get_session_booking_for_payment, Booking, :company_id => user.company_id

        can :get_booking, Booking, :location_id => user.locations.pluck(:id)
        can :get_booking_info, Booking, :location_id => user.locations.pluck(:id)
        can :available_providers, ServiceProvider, :location_id => user.locations.pluck(:id)
        can :provider_breaks, ProviderBreak
        can :get_provider_break, ProviderBreak
        can :create_provider_break, ProviderBreak
        can :update_provider_break, ProviderBreak
        can :destroy_provider_break, ProviderBreak
        can :update_repeat_break, ProviderBreak
        can :destroy_repeat_break, ProviderBreak

        # can :read, StaffCode, :company_id => user.company_id
        can :read, BookingHistory, :company_id => user.company_id

        can :read, Service, :company_id => user.company_id
        can :create, Service, :company_id => user.company_id
        can :update, Service, :company_id => user.company_id

        can :read, Bundle, :company_id => user.company_id
        can :create, Bundle, :company_id => user.company_id
        can :update, Bundle, :company_id => user.company_id

        can :read, ServiceCategory, :company_id => user.company_id
        can :create, ServiceCategory, :company_id => user.company_id
        can :update, ServiceCategory, :company_id => user.company_id

        can :read, ProviderGroup, :company_id => user.company_id
        can :create, ProviderGroup, :company_id => user.company_id
        can :update, ProviderGroup, :company_id => user.company_id

        can :history, Client, :company_id => user.company_id
        can :read, Client, :company_id => user.company_id
        can :bookings_content, Client, :company_id => user.company_id
        can :treatments_content, Client, :company_id => user.company_id
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

        can :locations_stats_excel, Product, :company_id => user.company_id
        can :logs_history_excel, Product, :company_id => user.company_id
        can :logs_history, Product, :company_id => user.company_id
        can :products, ProductCategory, :company_id => user.company_id
        can :history, Product, :company_id => user.company_id
        can :seller_history, Product, :company_id => user.company_id
        can :product_history, Product, :company_id => user.company_id
        can :stats, Product, :company_id => user.company_id
        can :locations_stats, Product, :company_id => user.company_id
        can :location_products, Location, :company_id => user.company_id
        can :get_staff_by_code, StaffCode, :company_id => user.company_id
        can :create_new_payment, Payment, :company_id => user.company_id
        can :alarm_form, Product, :company_id => user.company_id
        can :inventory, Location, :company_id => user.company_id
        can :set_alarm, Product, :company_id => user.company_id
        can :stock_alarm_form, Location, :company_id => user.company_id
        can :save_stock_alarm, Location, :company_id => user.company_id
        can :sellers, Location, :company_id => user.company_id
        can :get_by_code, Cashier, :company_id => user.company_id
        can :get_by_code, EmployeeCode, :company_id => user.company_id
        can :check_staff_code, EmployeeCode, :company_id => user.company_id
        can :receipt_pdf, Payment, :company_id => user.company_id
        can :payment_pdf, Payment, :company_id => user.company_id
        can :send_receipts_email, Payment, :company_id => user.company_id
        can :get_receipts, Payment, :company_id => user.company_id
        can :get_intro_info, Payment, :company_id => user.company_id
        can :save_intro_info, Payment, :company_id => user.company_id
        can :check_booking_payment, Payment, :company_id => user.company_id
        can :get_formatted_booking, Payment, :company_id => user.company_id
        can :commissions, Payment, :company_id => user.company_id

        can :summary, Payment, :company_id => user.company_id
        can :internal_sale_summary, Payment, :company_id => user.company_id

        can :sales_cash_transaction_summary, Payment, :company_id => user.company_id
        can :sales_cash_income_summary, Payment, :company_id => user.company_id

        can :provider_commissions, Payment, :company_id => user.company_id
        can :service_commissions, Payment, :company_id => user.company_id
        can :set_commissions, Payment, :company_id => user.company_id
        can :set_default_commission, Payment, :company_id => user.company_id
        can :set_provider_default_commissions, Payment, :company_id => user.company_id
        can :commissions_content, Payment, :company_id => user.company_id

        can :petty_cash, Payment, :company_id => user.company_id
        can :petty_transactions, Payment, :company_id => user.company_id
        can :petty_transaction, Payment, :company_id => user.company_id
        can :add_petty_transaction, Payment, :company_id => user.company_id
        can :open_close_petty_cash, Payment, :company_id => user.company_id
        can :delete_petty_transaction, Payment, :company_id => user.company_id
        can :set_petty_cash_close_schedule, Payment, :company_id => user.company_id

        #Sales Cash

        can :sales_cash, Payment, :company_id => user.company_id
        can :sales_cash_content, Payment, :company_id => user.company_id
        can :get_sales_cash, Payment, :company_id => user.company_id
        can :save_sales_cash, Payment, :company_id => user.company_id
        can :close_sales_cash, Payment, :company_id => user.company_id

        can :get_sales_cash_transaction, Payment, :company_id => user.company_id
        can :save_sales_cash_transaction, Payment, :company_id => user.company_id
        can :delete_sales_cash_transaction, Payment, :company_id => user.company_id

        can :get_sales_cash_income, Payment, :company_id => user.company_id
        can :save_sales_cash_income, Payment, :company_id => user.company_id
        can :delete_sales_cash_income, Payment, :company_id => user.company_id

        can :sales_cash_report_file, Payment, :company_id => user.company_id
        can :current_sales_cash_report_file, Payment, :company_id => user.company_id

        can :petty_cash_report, Payment, :company_id => user.company_id

        #Sales Reports
        can :sales_reports, Payment, :company_id => user.company_id
        can :service_providers_report, Payment, :company_id => user.company_id
        can :users_report, Payment, :company_id => user.company_id
        can :cashiers_report, Payment, :company_id => user.company_id
        can :service_providers_report_file, Payment, :company_id => user.company_id

        #Internal Sale
        can :save_internal_sale, Payment, :company_id => user.company_id
        can :delete_internal_sale, Payment, :company_id => user.company_id
        can :get_internal_sale, Payment, :company_id => user.company_id
        can :get_product_for_payment_or_sale, Payment, :company_id => user.company_id
        can :get_products_for_payment_or_sale, Payment, :company_id => user.company_id
        can :get_product_brands_for_payment_or_sale, Payment, :company_id => user.company_id
        can :get_product_categories_for_payment_or_sale, Payment, :company_id => user.company_id

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
        can :client_treatments, Payment
        can :client_sessions, Payment
        can :index_content, Payment
        can :read, Payment, :company_id => user.company_id
        can :destroy, Payment, :company_id => user.company_id
        can :create, Payment, :company_id => user.company_id
        can :update, Payment, :company_id => user.company_id
        can :delete_payment, Payment, :company_id => user.company_id
        can :update_payment, Payment, :company_id => user.company_id

        can :compose_mail, Client, :company_id => user.company_id
        can :send_mail, Client, :company_id => user.company_id
        can :campaigns_report_content, Client, :company_id => user.company_id
        can :campaign_report_details, Client, :company_id => user.company_id
        can :import, Client
        can :download, Client
        can :file_generation, Client

        can :import, Product
        can :download, Product

        can :change_categories_order, ServiceCategory
        can :change_services_order, Service
        can :change_location_order, Location
        can :change_providers_order, ServiceProvider
        can :change_groups_order, ProviderGroup

        can :country_regions, Region
        can :region_cities, City
        can :city_districs, District

        can :save_billing_wire_transfer, Plan, :company_id => user.company_id

        can :read, ClientFile, :client => {:company_id => user.company_id}
        can :create, ClientFile, :client => {:company_id => user.company_id}
        can :update, ClientFile, :client => {:company_id => user.company_id}
        can :destroy, ClientFile, :client => {:company_id => user.company_id}

        can :files, Client, :company_id => user.company_id
        can :upload_file, Client, :company_id => user.company_id
        can :create_folder, Client, :company_id => user.company_id
        can :rename_folder, Client, :company_id => user.company_id
        can :delete_folder, Client, :company_id => user.company_id
        can :move_file, Client, :company_id => user.company_id
        can :edit_file, Client, :company_id => user.company_id

        can :get_attribute_categories, Attribute, :company_id => user.company_id
        can :get_chart_categories, ChartField, :company_id => user.company_id
        can :update_custom_attributes, Client, :company_id => user.company_id

        can :read, AppFeed, :company_id => user.company_id
        can :create, AppFeed, :company_id => user.company_id
        can :update, AppFeed, :company_id => user.company_id
        can :destroy, AppFeed, :company_id => user.company_id

    elsif user.role_id == Role.find_by_name("Recepcionista").id

        can :summary, Booking, :company_id => user.company_id
        can :chart, Booking, :company_id => user.company_id
        can :print, Client, :company_id => user.company_id
        can :print, Chart, :company_id => user.company_id

        can :bookings, Chart, :company_id => user.company_id
        can :summary, Chart, :company_id => user.company_id
        can :read, Chart, :company_id => user.company_id
        can :destroy, Chart, :company_id => user.company_id
        can :create, Chart, :company_id => user.company_id
        can :update, Chart, :company_id => user.company_id
        can :edit_form, Chart, :company_id => user.company_id
        can :merge, Client, :company_id => user.company_id

        can :get_attribute_categories, Attribute, :company_id => user.company_id
        can :get_chart_categories, ChartField, :company_id => user.company_id
        can :update_custom_attributes, Client, :company_id => user.company_id

        can :get_custom_attributes, Client, :company_id => user.company_id

        can :payments, Client, :company_id => user.company_id
        can :payments_content, Client, :company_id => user.company_id
        can :emails, Client, :company_id => user.company_id
        can :emails_content, Client, :company_id => user.company_id
        can :last_payments, Client, :company_id => user.company_id
        can :charts, Client, :company_id => user.company_id
        can :charts_content, Client, :company_id => user.company_id

        can :delete_treatment, Booking, :company_id => user.company_id
        can :delete_client_treatment, Booking, :company_id => user.company_id
        can :get_treatment_info, Booking, :company_id => user.company_id
        can :get_email_logs, Booking, :company_id => user.company_id
        can :location_users, User, :company_id => user.company_id

        can :index_content, Payment

        can :get_booking_for_payment, Booking, :company_id => user.company_id
        can :get_session_booking_for_payment, Booking, :company_id => user.company_id

        can :get_booking, Booking, :location_id => user.locations.pluck(:id)
        can :get_booking_info, Booking, :location_id => user.locations.pluck(:id)
        can :available_providers, ServiceProvider, :location_id => user.locations.pluck(:id)
        can :provider_breaks, ProviderBreak
        can :get_provider_break, ProviderBreak
        can :create_provider_break, ProviderBreak
        can :update_provider_break, ProviderBreak
        can :destroy_provider_break, ProviderBreak
        can :update_repeat_break, ProviderBreak
        can :destroy_repeat_break, ProviderBreak

        can :read, Service, :company_id => user.company_id

        can :read, ServiceProvider, :location_id => user.locations.pluck(:id)

        can :read, Location, :id => user.locations

        can :read, ProviderTime, :service_provider => { :location_id => user.locations.pluck(:id) }

        can :history, Client, :company_id => user.company_id
        can :read, Client, :company_id => user.company_id
        can :bookings_content, Client, :company_id => user.company_id
        can :treatments_content, Client, :company_id => user.company_id
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
        can :client_treatments, Payment
        can :client_sessions, Payment
        can :read, Payment, :company_id => user.company_id
        can :create, Payment, :company_id => user.company_id
        can :sellers, Location, :company_id => user.company_id

        can :create_comment, Client, :company_id => user.company_id
        can :update_comment, Client, :company_id => user.company_id
        can :destroy_comment, Client, :company_id => user.company_id

        can :compose_mail, Client, :company_id => user.company_id
        can :send_mail, Client, :company_id => user.company_id
        can :campaigns_report_content, Client, :company_id => user.company_id
        can :campaign_report_details, Client, :company_id => user.company_id
        can :import, Client
        can :download, Client
        can :file_generation, Client

        can :locations_stats_excel, Product, :company_id => user.company_id
        can :logs_history_excel, Product, :company_id => user.company_id
        can :logs_history, Product, :company_id => user.company_id
        can :products, ProductCategory, :company_id => user.company_id
        can :history, Product, :company_id => user.company_id
        can :seller_history, Product, :company_id => user.company_id
        can :product_history, Product, :company_id => user.company_id
        can :stats, Product, :company_id => user.company_id
        can :locations_stats, Product, :company_id => user.company_id
        can :location_products, Location, :company_id => user.company_id
        can :get_staff_by_code, StaffCode, :company_id => user.company_id
        can :create_new_payment, Payment, :company_id => user.company_id
        can :get_by_code, Cashier, :company_id => user.company_id
        can :get_by_code, EmployeeCode, :company_id => user.company_id
        can :check_staff_code, EmployeeCode, :company_id => user.company_id
        can :receipt_pdf, Payment, :company_id => user.company_id
        can :payment_pdf, Payment, :company_id => user.company_id
        can :send_receipts_email, Payment, :company_id => user.company_id
        can :get_receipts, Payment, :company_id => user.company_id
        can :get_intro_info, Payment, :company_id => user.company_id
        can :save_intro_info, Payment, :company_id => user.company_id
        can :check_booking_payment, Payment, :company_id => user.company_id
        can :get_formatted_booking, Payment, :company_id => user.company_id

        can :inventory, Location, :company_id => user.company_id
        can :inventory, Company, :company_id => user.company_id
        can :index, Product, :company_id => user.company_id
        can :read, Product, :company_id => user.company_id

        can :summary, Payment, :company_id => user.company_id
        can :internal_sale_summary, Payment, :company_id => user.company_id

        #Internal Sale
        can :save_internal_sale, Payment, :company_id => user.company_id
        can :get_product_for_payment_or_sale, Payment, :company_id => user.company_id

        can :get_products_for_payment_or_sale, Payment, :company_id => user.company_id
        can :get_product_brands_for_payment_or_sale, Payment, :company_id => user.company_id
        can :get_product_categories_for_payment_or_sale, Payment, :company_id => user.company_id


        can :petty_cash, Payment, :company_id => user.company_id
        can :petty_transactions, Payment, :company_id => user.company_id
        can :petty_transaction, Payment, :company_id => user.company_id
        can :add_petty_transaction, Payment, :company_id => user.company_id
        can :open_close_petty_cash, Payment, :company_id => user.company_id
        can :delete_petty_transaction, Payment, :company_id => user.company_id
        can :set_petty_cash_close_schedule, Payment, :company_id => user.company_id

        #Sales Reports
        can :sales_reports, Payment, :company_id => user.company_id
        can :users_report, Payment, :company_id => user.company_id
        can :service_providers_report, Payment, :company_id => user.company_id
        can :service_providers_report_file, Payment, :company_id => user.company_id


        can :read, ClientFile, :client => {:company_id => user.company_id}
        can :create, ClientFile, :client => {:company_id => user.company_id}
        can :update, ClientFile, :client => {:company_id => user.company_id}
        can :destroy, ClientFile, :client => {:company_id => user.company_id}

        can :files, Client, :company_id => user.company_id
        can :upload_file, Client, :company_id => user.company_id
        can :create_folder, Client, :company_id => user.company_id
        can :rename_folder, Client, :company_id => user.company_id
        can :delete_folder, Client, :company_id => user.company_id
        can :move_file, Client, :company_id => user.company_id
        can :edit_file, Client, :company_id => user.company_id

    elsif user.role_id == Role.find_by_name("Staff").id

        can :summary, Booking, :company_id => user.company_id
        can :chart, Booking, :company_id => user.company_id
        can :print, Client, :company_id => user.company_id
        can :print, Chart, :company_id => user.company_id

        can :bookings, Chart, :company_id => user.company_id
        can :summary, Chart, :company_id => user.company_id
        can :read, Chart, :company_id => user.company_id
        can :destroy, Chart, :company_id => user.company_id
        can :create, Chart, :company_id => user.company_id
        can :update, Chart, :company_id => user.company_id
        can :edit_form, Chart, :company_id => user.company_id

        can :get_attribute_categories, Attribute, :company_id => user.company_id
        can :get_chart_categories, ChartField, :company_id => user.company_id
        can :update_custom_attributes, Client, :company_id => user.company_id

        can :get_custom_attributes, Client, :company_id => user.company_id

        can :last_payments, Client, :company_id => user.company_id

        can :delete_treatment, Booking, :company_id => user.company_id
        can :delete_client_treatment, Booking, :company_id => user.company_id
        can :get_treatment_info, Booking, :company_id => user.company_id
        can :get_email_logs, Booking, :company_id => user.company_id
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
        can :update_repeat_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)
        can :destroy_repeat_break, ProviderBreak, :service_provider_id => user.service_providers.pluck(:id)

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
        can :client_treatments, Payment
        can :client_sessions, Payment
        can :read, Payment, :company_id => user.company_id
        can :create, Payment, :company_id => user.company_id
        can :sellers, Location, :company_id => user.company_id

        can :location_products, Location, :company_id => user.company_id
        can :get_staff_by_code, StaffCode, :company_id => user.company_id
        can :create_new_payment, Payment, :company_id => user.company_id
        can :get_by_code, Cashier, :company_id => user.company_id
        can :get_by_code, EmployeeCode, :company_id => user.company_id
        can :check_staff_code, EmployeeCode, :company_id => user.company_id
        can :receipt_pdf, Payment, :company_id => user.company_id
        can :payment_pdf, Payment, :company_id => user.company_id
        can :send_receipts_email, Payment, :company_id => user.company_id
        can :get_receipts, Payment, :company_id => user.company_id
        can :get_intro_info, Payment, :company_id => user.company_id
        can :save_intro_info, Payment, :company_id => user.company_id
        can :check_booking_payment, Payment, :company_id => user.company_id
        can :get_formatted_booking, Payment, :company_id => user.company_id

        can :summary, Payment, :company_id => user.company_id
        can :internal_sale_summary, Payment, :company_id => user.company_id

        can :petty_cash, Payment, :company_id => user.company_id
        can :petty_transactions, Payment, :company_id => user.company_id
        can :petty_transaction, Payment, :company_id => user.company_id
        can :add_petty_transaction, Payment, :company_id => user.company_id
        can :open_close_petty_cash, Payment, :company_id => user.company_id
        can :delete_petty_transaction, Payment, :company_id => user.company_id
        can :set_petty_cash_close_schedule, Payment, :company_id => user.company_id

        #Sales Reports
        can :sales_reports, Payment, :company_id => user.company_id
        can :service_providers_report, Payment, :company_id => user.company_id
        can :users_report, Payment, :company_id => user.company_id
        can :service_providers_report_file, Payment, :company_id => user.company_id

        can :read, ClientFile, :client => {:company_id => user.company_id}
        can :create, ClientFile, :client => {:company_id => user.company_id}
        can :update, ClientFile, :client => {:company_id => user.company_id}
        can :destroy, ClientFile, :client => {:company_id => user.company_id}

        can :files, Client, :company_id => user.company_id
        can :upload_file, Client, :company_id => user.company_id
        can :create_folder, Client, :company_id => user.company_id
        can :rename_folder, Client, :company_id => user.company_id
        can :delete_folder, Client, :company_id => user.company_id
        can :move_file, Client, :company_id => user.company_id
        can :edit_file, Client, :company_id => user.company_id

        can :payments, Client, :company_id => user.company_id
        can :payments_content, Client, :company_id => user.company_id
        can :emails, Client, :company_id => user.company_id
        can :emails_content, Client, :company_id => user.company_id
        can :last_payments, Client, :company_id => user.company_id
        can :charts, Client, :company_id => user.company_id
        can :charts_content, Client, :company_id => user.company_id

        can :update_custom_attributes, Client, :company_id => user.company_id
        can :create_comment, Client
        can :update_comment, Client
        can :destroy_comment, Client
        can :edit, Client, :company_id => user.company_id
        can :update, Client, :company_id => user.company_id
        can :history, Client, :company_id => user.company_id
        can :read, Client, :company_id => user.company_id
        can :bookings_content, Client, :company_id => user.company_id
        can :treatments_content, Client, :company_id => user.company_id

    elsif user.role_id == Role.find_by_name("Staff (sin edición)").id

        can :summary, Booking, :company_id => user.company_id
        can :chart, Booking, :company_id => user.company_id
        can :print, Client, :company_id => user.company_id
        can :print, Chart, :company_id => user.company_id

        can :bookings, Chart, :company_id => user.company_id
        can :summary, Chart, :company_id => user.company_id
        can :read, Chart, :company_id => user.company_id

        can :get_attribute_categories, Attribute, :company_id => user.company_id
        can :get_chart_categories, ChartField, :company_id => user.company_id
        can :update_custom_attributes, Client, :company_id => user.company_id

        can :get_custom_attributes, Client, :company_id => user.company_id

        can :last_payments, Client, :company_id => user.company_id

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

        #Sales Reports
        can :sales_reports, Payment, :company_id => user.company_id
        can :service_providers_report, Payment, :company_id => user.company_id
        can :users_report, Payment, :company_id => user.company_id
        can :service_providers_report_file, Payment, :company_id => user.company_id

        can :summary, Payment, :company_id => user.company_id
        can :internal_sale_summary, Payment, :company_id => user.company_id

    elsif user.role_id == Role.find_by_name("Ventas").id

        can :manage, Company
        can :manage_company, Company
        can :index, Dashboard
    end

  end
end
