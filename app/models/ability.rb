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

    company_abilities = [User, Location, ServiceProvider, Service]


    user ||= User.new # guest user (not logged in)

    can :new, :all

    # Home
    can :view_plans, Plan

    # Workflow
    can :overview, Company
    can :workflow, Company
    can :location_data, Location
    can :service_data, Service
    can :services_data, Service
    can :get_providers, Service
    can :provider_booking, Booking
    can :book_service, Booking
    can :location_services, ServiceProvider
    can :location_providers, ServiceProvider
    can :provider_time, ServiceProvider
    can :location_time, Location
    can :get_category_name, ServiceCategory
    can :get_available_time, Location

    # Search
    can :get_districts, District
    can :get_district, District
    can :get_district_by_name, District

    can :get_direction, District

    can :read, Booking, :user_id => user.id
    can :update, Booking, :user_id => user.id
    can :destroy, Booking, :user_id => user.id
    can :create, Booking, :user_id => user.id


    if user.role_id == Role.find_by_name("Super Admin").id

        can :manage, :all

    elsif user.role_id == Role.find_by_name("Admin").id

        can :select_plan, Plan

        can :get_booking, Booking

        can :read, Company, :id => user.company_id
        can :destroy, Company, :id => user.company_id
        can :create, Company, :id => user.company_id
        can :update, Company, :id => user.company_id

        company_abilities.each do |c|
            can :read, c, :company_id => user.company_id
            can :destroy, c, :company_id => user.company_id
            can :create, c, :company_id => user.company_id
            can :update, c, :company_id => user.company_id
        end

        can :read, CompanySetting, :company_id => user.company_id
        can :destroy, CompanySetting, :company_id => user.company_id
        can :create, CompanySetting, :company_id => user.company_id
        can :update, CompanySetting, :company_id => user.company_id

        can :read, ServiceCategory, :company_id => user.company_id
        can :destroy, ServiceCategory, :company_id => user.company_id
        can :create, ServiceCategory, :company_id => user.company_id
        can :update, ServiceCategory, :company_id => user.company_id

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

    elsif user.role_id == Role.find_by_name("Administrador Local").id

        can :get_booking, Booking, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }

        can :read, Service, :company_id => user.company_id
        can :destroy, Service, :company_id => user.company_id
        can :create, Service, :company_id => user.company_id
        can :update, Service, :company_id => user.company_id

        can :read, ServiceProvider, :location_id => user.try(:service_providers).try(:location_id)
        can :destroy, ServiceProvider, :location_id => user.try(:service_providers).try(:location_id)
        can :create, ServiceProvider, :location_id => user.try(:service_providers).try(:location_id)
        can :update, ServiceProvider, :location_id => user.try(:service_providers).try(:location_id)

        can :read, Location, :id => user.try(:service_provider).try(:location_id)
        can :destroy, Location, :id => user.try(:service_provider).try(:location_id)
        can :create, Location, :id => user.try(:service_provider).try(:location_id)
        can :update, Location, :id => user.try(:service_provider).try(:location_id)

        can :read, LocationTime, :location_id => user.try(:service_providers).try(:location_id)
        can :destroy, LocationTime, :location_id => user.try(:service_providers).try(:location_id)
        can :create, LocationTime, :location_id => user.try(:service_providers).try(:location_id)
        can :update, LocationTime, :location_id => user.try(:service_providers).try(:location_id)

        can :read, ProviderTime, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }
        can :destroy, ProviderTime, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }
        can :create, ProviderTime, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }
        can :update, ProviderTime, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }

        can :read, Booking, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }
        can :destroy, Booking, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }
        can :create, Booking, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }
        can :update, Booking, :service_provider => { :location_id => user.try(:service_providers).try(:location_id) }
        
    end

  end
end
