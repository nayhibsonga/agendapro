class Location < ActiveRecord::Base
  require 'pg_search'
  include PgSearch

  belongs_to :country
  belongs_to :company

  has_many :location_times, dependent: :destroy

  has_many :service_providers, dependent: :destroy
  has_many :active_service_providers, -> { where active: true}, class_name: "ServiceProvider"

  has_many :bookings, dependent: :destroy

  has_many :resource_locations, dependent: :destroy
  has_many :resources, :through => :resource_locations

  has_many :user_locations, dependent: :destroy
  has_many :users, :through => :user_locations

  has_many :notification_locations, dependent: :destroy
  has_many :notification_emails, :through => :notification_locations


  has_many :last_minute_services, -> { where has_last_minute_discount: true }

	#has_many :time_promotion_services, -> { where active: true }, :through => :service_providers

  has_many :services, -> { where active: true, online_booking: true }, :through => :active_service_providers

  #has_many :services, -> { where active: true }, :through => :service_providers

  has_many :service_categories, :through => :services

  has_many :economic_sectors, :through => :company
  has_many :economic_sectors_dictionaries, :through => :economic_sectors

  has_many :promos

  accepts_nested_attributes_for :location_times, :reject_if => :all_blank, :allow_destroy => true

  has_many :payments, dependent: :destroy
  has_many :internal_sales, dependent: :destroy

  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user

  has_many :location_products, dependent: :destroy
  has_many :products, through: :location_products
  has_one :stock_alarm_setting, dependent: :destroy
  has_one :sales_cash, dependent: :destroy
  has_many :sendings, class_name: 'Email::Sending', as: :sendable
  has_many :location_open_days, dependent: :destroy

  mount_uploader :image1, LocationImagesUploader
  mount_uploader :image2, LocationImagesUploader
  mount_uploader :image3, LocationImagesUploader

  scope :actives, -> { where(active: true) }

  scope :ordered, -> { order(:order, :name) }

  validates :name, :phone, :company, :country, :email, :presence => true

  validate :times_overlap, :time_empty_or_negative, :plan_locations, :outcall_services, :active_countries
  validate :new_plan_locations, :on => :create

  validation_scope :warnings do |s|
    s.validate after_commit :provider_time_in_location_time
  end

  after_commit :extended_schedule
  after_create :add_products, :create_location_process, :create_sales_cashes
  after_update :update_location_process
  after_destroy :destroy_location_process

  pg_search_scope :search_company_name, :associated_against => {
    :company => :name
  },
  :using => {
    :trigram => {
      :threshold => 0.1,
      :prefix => true,
      :any_word => true
    },
    :tsearch => {
      :prefix => true,
      :any_word => true
    }
  },
  :ignoring => :accents,
  :ranked_by => ":tsearch + (0.5 * :trigram)"

  pg_search_scope :search, :associated_against => {
    :company => [:name, :web_address],
    :economic_sectors => :name,
    :economic_sectors_dictionaries => :name,
    :service_categories => :name,
    :services => :name
  },
  :using => {
	  :trigram => {
	    :threshold => 0.1,
	    :prefix => true,
	    :any_word => true
	  	},
      :tsearch => {
      	:prefix => true,
      	:any_word => true
      }
  },
  :ignoring => :accents

  pg_search_scope :search_services, :associated_against => {
  	:services => :name,
  	:service_categories => :name,
  	:economic_sectors => :name,
  	:economic_sectors_dictionaries => :name
  },
  :using => {
      :trigram => {
        	:threshold => 0.1,
        	:prefix => true,
      	:any_word => true
      },
      :tsearch => {
      	:prefix => true,
      	:any_word => true
      }
  },
  :ignoring => :accents

  WORKER = 'StockEmailWorker'

    def adjust_times
      for i in 1..7
        location_time = self.location_times.where(day_id: i).first
        pg_day = i
        if i == 7
          pg_day = 0
        end
        #If location_time doesn't exist, make location_open_day checks or destroy provider_open_days if no location_open_days exist
        if location_time.nil?
          ProviderOpenDay.where(service_provider_id: ServiceProvider.where(location_id: self.id).pluck(:id)).where('extract(dow from start_time) = ?', pg_day).each do |provider_open_day|
            if self.location_open_days.where('(location_open_days.start_time, location_open_days.end_time) OVERLAPS (?, ?)', provider_open_day.start_time, provider_open_day.end_time).count > 0
              self.location_open_days.where('(location_open_days.start_time, location_open_days.end_time) OVERLAPS (?, ?)', provider_open_day.start_time, provider_open_day.end_time).each do |location_open_day|
                location_open_day.fix_provider_open_days
              end
            else
              provider_open_day.destroy
            end
          end
        else
        #If it does exist, make general check (location_time.fix_provider_open_days)
          location_time.fix_provider_open_days
        end
      end
    end

    def is_open(start_time, end_time)

      location = self
      correct_time = false

      #Check for location_times first
      if location.location_times.where(day_id: start_time.to_datetime.cwday).count > 0
        location.location_times.where(day_id: start_time.to_datetime.cwday).each do |location_time|
          if (location_time.open.strftime('%R') <= start_time.strftime("%R") && location_time.close.strftime('%R') >= end_time.strftime('%R'))
            correct_time = true
            break
          end
        end
      end

      #If there was no location_time, check for an open_day
      if !correct_time
        if (location.location_open_days.where('start_time <= ? and end_time >= ?', start_time, end_time).count > 0)
          correct_time = true
        end
      end

      return correct_time

    end

    def create_sales_cashes
      sales_cash = SalesCash.create(:location_id => self.id, :cash => 0, :last_reset_date => DateTime.now)
      petty_cash = PettyCash.create(:location_id => self.id, :cash => 0, :open => true)
    end

  	#Add due if plan is not custom and locations increased by one
  	def add_due
  		# if !self.company.plan.custom
  		# 	company = self.company
  		# 	day_number = DateTime.now.day
    # 		month_number = DateTime.now.month
    # 		month_days = DateTime.now.days_in_month
  		# 	company.due_amount += (((month_days - day_number + 1).to_f / month_days.to_f) * company.company_plan_setting.base_price * company.computed_multiplier).round(2)
  		# 	company.save
  		# end
  	end

    #After creation, check if there is more than one location.
    #If so, adjust due according to current status.
    def create_location_process
      if !self.company.plan.custom
        if self.company.locations.count > 1
          company = self.company
          day_number = DateTime.now.day
          month_number = DateTime.now.month
          month_days = DateTime.now.days_in_month

          #Process changes according to status.
          #If status is "Activo", then current month was already payed and due_amount should increase for the new location for month's days left and all months active left.
          #If status is "Emitido", "Vencido" or "Bloqueado", then month hasn't been payed and the price will rise, so we should substract due_amount for month's days past.
          if company.payment_status = PaymentStatus.find_by_name("Activo")
            #Increase is: days_left * base_price * 0.5
            company.due_amount += (((month_days - day_number + 1).to_f / month_days.to_f) * company.company_plan_setting.base_price * 0.5) + (company.company_plan_setting.base_price * 0.5) * (company.months_active_left - 1)
            company.save
          elsif ["Emitido", "Vencido", "Bloqueado"].include?(company.payment_status.name)
            #Decrease is: past_days * base_price * 0.5
            company.due_amount -= ((day_number).to_f / month_days.to_f) * company.company_plan_setting.base_price * 0.5
            company.save
          end

        end
      end
    end

    #Check if a location has been deactivated or reactivated
    #If so, adjust due according to current status.
    def update_location_process
      if !self.company.plan.custom
        if self.active_changed?
          company = self.company
          day_number = DateTime.now.day
          month_number = DateTime.now.month
          month_days = DateTime.now.days_in_month

          if self.active
            #Process changes according to company status.
            #If status is "Activo", then current month was already payed and due_amount should increase for the new location for month's days left and all payed months.
            #If status is "Emitido", "Vencido" or "Bloqueado", then month hasn't been payed and the price will rise, so we should substract due_amount for month's days past.
            if company.payment_status = PaymentStatus.find_by_name("Activo")
              #Increase is: days_left * base_price * 0.5
              company.due_amount += (((month_days - day_number + 1).to_f / month_days.to_f) * company.company_plan_setting.base_price * 0.5 ) + (company.company_plan_setting.base_price * 0.5) * (company.months_active_left - 1)
              company.save
              puts "Due: " + company.due_amount.to_s
              puts "Active location, company Activo"
            elsif ["Emitido", "Vencido", "Bloqueado"].include?(company.payment_status.name)
              #Decrease is: past_days * base_price * 0.5
              company.due_amount -= ((day_number).to_f / month_days.to_f) * company.company_plan_setting.base_price * 0.5
              company.save
              puts "Due: " + company.due_amount.to_s
              puts "Active location, company not Activo"
            end
          else
            #Process changes according to company status.
            #If status is "Activo", the current month was already payed and due_amount should decrease for the new location for month's day left and all payed months.
            #If status is "Emitido", "Vencido" or "Bloqueado", then month hasn't been payed and the price will lower, so we should add due_amount for month's days past.
            if company.payment_status = PaymentStatus.find_by_name("Activo")
              company.due_amount -= ((((month_days - day_number + 1).to_f / month_days.to_f) * company.company_plan_setting.base_price * 0.5 ) + (company.company_plan_setting.base_price * 0.5) * (company.months_active_left - 1))
              company.save
              puts "Due: " + company.due_amount.to_s
              puts "Inactive location, company Activo"
            elsif ["Emitido", "Vencido", "Bloqueado"].include?(company.payment_status.name)
              company.due_amount += ((day_number).to_f / month_days.to_f) * company.company_plan_setting.base_price * 0.5
              company.save
              puts "Due: " + company.due_amount.to_s
              puts "Inactive location, company not Activo"
            end
          end

        end
      end
    end

    #After destruction, adjust due according to current status.
    def destroy_location_process
      if !self.company.plan.custom
        if self.company.locations.count > 0
          company = self.company
          day_number = DateTime.now.day
          month_number = DateTime.now.month
          month_days = DateTime.now.days_in_month

          #Process changes according to company status.
          #If status is "Activo", the current month was already payed and due_amount should decrease for the new location for month's day left and all payed months.
          #If status is "Emitido", "Vencido" or "Bloqueado", then month hasn't been payed and the price will lower, so we should add due_amount for month's days past.
          if company.payment_status = PaymentStatus.find_by_name("Activo")
            company.due_amount -= ((((month_days - day_number + 1).to_f / month_days.to_f) * company.company_plan_setting.base_price * 0.5 ) + (company.company_plan_setting.base_price * 0.5) * (company.months_active_left - 1))
            company.save
          elsif ["Emitido", "Vencido", "Bloqueado"].include?(company.payment_status.name)
            company.due_amount += ((day_number).to_f / month_days.to_f) * company.company_plan_setting.base_price * 0.5
            company.save
          end

        end
      end
    end

  	#Substract due if plan is not custom and locations decreased by one
  	def substract_due
  		# if !self.company.plan.custom
  		# 	company = self.company
  		# 	day_number = DateTime.now.day
    # 		month_number = DateTime.now.month
    # 		month_days = DateTime.now.days_in_month
  		# 	company.due_amount -= (((month_days - day_number + 1).to_f / month_days.to_f) * company.company_plan_setting.base_price * (company.computed_multiplier + company.company_plan_setting.locations_multiplier)).round(2)
  		# 	company.save
  		# end
  	end

  	def add_products
  		Product.where(:company_id => self.company.id).each do |product|
  			if LocationProduct.where(:product_id => product.id, :location_id => self.id).count == 0
  				location_product = LocationProduct.create(:product_id => product.id, :location_id => self.id, :stock => 0)
  			end
  		end
      StockAlarmSetting.create(location_id: self.id, quick_send: false, has_default_stock_limit: false, default_stock_limit: 0, monthly: true, month_day: 1, week_day: 1, periodic_send: false)
  	end

	def extended_schedule
		company_setting = self.company.company_setting
		location_ids = self.company.locations.pluck(:id)
		changed = false
		first_open_time = LocationTime.where(location_id: location_ids).order(:open).first.open
		last_close_time = LocationTime.where(location_id: location_ids).order(:close).last.close
		if company_setting.extended_min_hour > first_open_time
			company_setting.extended_min_hour = first_open_time
			changed = true
		end
		if company_setting.extended_max_hour < last_close_time
			company_setting.extended_max_hour = last_close_time
			changed = true
		end
		if changed
			company_setting.save
		end
	end

	def plan_locations
		if self.active_changed? && self.active
			if self.company.locations.where(active:true).count >= self.company.plan.locations && (self.company.plan.custom || self.company.plan.name == "Personal")
				errors.add(:base, "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
			end
		else
			if self.company.locations.where(active:true).count > self.company.plan.locations && (self.company.plan.custom || self.company.plan.name == "Personal")
				errors.add(:base, "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
			end
		end
	end

	def new_plan_locations
		if self.company.locations.where(active:true).count >= self.company.plan.locations && (self.company.plan.custom || self.company.plan.name == "Personal")
			errors.add(:base, "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
		end
	end

	def outcall_services
		if self.outcall
			notOutcall = false
			self.service_providers.each do |service_provider|
				if service_provider.active
					service_provider.services.each do |service|
						if service.active && !service.outcall
							notOutcall = true
						end
					end
				end
			end
			if notOutcall
				errors.add(:base, "El local a domicilio no puede tener prestadores que realizan servicios que no son a domicilio.")
			end
		end
	end

	def times_overlap
    self.location_times.each do |location_time1|
			self.location_times.each do |location_time2|
				if (location_time1 != location_time2)
					if(location_time1.day_id == location_time2.day_id)
						if (location_time1.open - location_time2.close) * (location_time2.open - location_time1.close) >= 0
				      		errors.add(:base, "Existen bloques horarios sobrepuestos para el día "+location_time1.day.name+".")
			    	end
		    	end
		    end
			end
		end
  end

  def time_empty_or_negative
  	self.location_times.each do |location_time|
			if location_time.open >= location_time.close
				errors.add(:base, "El horario del día "+location_time.day.name+" es vacío o negativo.")
			end
		end
	end

  def provider_time_in_location_time
    providers = []
  	self.service_providers.where(active: true).each do |service_provider|
			service_provider.provider_times.each do |provider_time|
				provider_time_open = provider_time.open.clone()
				provider_time_close = provider_time.close.clone()
				self.location_times.where(day_id: provider_time.day_id).each do |location_time|
          if (provider_time_open.change(:month => 1, :day => 1, :year => 2000) < location_time.open) || (provider_time_close.change(:month => 1, :day => 1, :year => 2000) > location_time.close)
            if !providers.include?(service_provider.public_name)
              providers << service_provider.public_name
            end
            provider_time.open = provider_time_open < location_time.open || provider_time_open > location_time.close ? location_time.open : provider_time_open
            provider_time.close = provider_time_close > location_time.close || provider_time_close < location_time.open ? location_time.close : provider_time_close
            provider_time.save
          end
				end
      end
      # Delete days
      location_days = service_provider.provider_times.pluck(:day_id).delete_if { |time| self.location_times.pluck(:day_id).include? time }
      provider_days = service_provider.provider_times.where(day_id: location_days)
      if provider_days.count > 0
        if !providers.include?(service_provider.public_name)
          providers << service_provider.public_name
        end
        provider_days.destroy_all
      end
		end
    warnings.add(:base, "El horario de #{providers.join(', ').gsub(/\,(?=[^,]*$)/, ' y')} ha sido ajustado al nuevo horario del local.") if providers.any?
	end

	def active_countries
		if self.active && CompanyCountry.where(country_id: self.country_id, company_id: self.company_id).count < 1
			errors.add(:base, "No puedes guardar el local ya que no tienes ese país activo en tus configuraciones.")
		end
	end

  def categorized_services

    location_resources = self.resource_locations.pluck(:resource_id)
    service_providers = self.service_providers.where(active: true, online_booking: true)

    categories = ServiceCategory.where(:company_id => self.company_id).order(:order, :name)
    services = Service.where(:active => true, online_booking: true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(:order, :name)
    service_resources_unavailable = ServiceResource.where(service_id: services)
    if location_resources.any?
      if location_resources.length > 1
        service_resources_unavailable = service_resources_unavailable.where('resource_id NOT IN (?)', location_resources)
      else
        service_resources_unavailable = service_resources_unavailable.where('resource_id <> ?', location_resources)
      end
    end
    if service_resources_unavailable.any?
      if service_resources_unavailable.length > 1
        services = services.where('services.id NOT IN (?)', service_resources_unavailable.pluck(:service_id))
      else
        services = services.where('id <> ?', service_resources_unavailable.pluck(:service_id))
      end
    end

    categorized_services = Array.new
    categories.each do |category|
      services_array = Array.new
      services.each do |service|
        if service.service_category_id == category.id
          serviceJSON = service.attributes.merge({'name_with_small_outcall' => service.name_with_small_outcall })
          services_array.push(serviceJSON)
        end
      end
      service_hash = {
        :id => category.id,
        :category => category.name,
        :services => services_array
      }
      categorized_services.push(service_hash)
    end


    return categorized_services

    # service_providers = self.service_providers
    # services_ids = Array.new
    # services = Array.new
    # categories = Array.new
    # service_providers.each do |sp|
    #   sp.services.where(active: true).each do |s|
    #     services_ids.push(s.id)
    #     services.push(s)
    #     if(!categories.include?(s.service_category))
    #       categories.push(s.service_category)
    #     end
    #   end
    # end

  end

	def api_categorized_services(bundle = false)

    location_resources = self.resource_locations.pluck(:resource_id)
    service_providers = self.service_providers.where(active: true, online_booking: true)

    categories = ServiceCategory.where(:company_id => self.company_id).order(:order, :name)
      services = Service.where(:active => true, online_booking: true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(:order, :name)
      service_resources_unavailable = ServiceResource.where(service_id: services)
      if location_resources.any?
        if location_resources.length > 1
          service_resources_unavailable = service_resources_unavailable.where('resource_id NOT IN (?)', location_resources)
        else
          service_resources_unavailable = service_resources_unavailable.where('resource_id <> ?', location_resources)
        end
      end
      if service_resources_unavailable.any?
        if service_resources_unavailable.length > 1
          services = services.where('services.id NOT IN (?)', service_resources_unavailable.pluck(:service_id))
        else
          services = services.where('id <> ?', service_resources_unavailable.pluck(:service_id))
        end
      end
      bundles = Bundle.where(id: ServiceBundle.where(service_id: services.pluck(:id)).pluck(:bundle_id))

      puts bundles.inspect

      categorized_services = Array.new
      categories.each do |category|
        services_array = Array.new
        services.each do |service|
          if service.service_category_id == category.id
            service_providers_array = []
            service.service_providers.where(active: true, online_booking: true, location_id: self.id).each do |service_provider|
              service_providers_array.push({id: service_provider.id, public_name: service_provider.public_name})
            end
            service_info = {
              id: service.id,
              name: service.name,
              price: service.show_price && service.price > 0 ? service.price : "",
              duration: service.duration,
              service_category_id: service.service_category_id,
              order: service.order,
              bundled: false,
              bundle: [],
              description: service.description,
              service_providers: service_providers_array,
              promo_active: service.has_time_discount && service.online_payable && service.time_promo_active,
              promo_hours: service.active_service_promo_id && ServicePromo.find(service.active_service_promo_id) ? ServicePromo.select(:id, :morning_start, :morning_end, :afternoon_start, :afternoon_end, :night_start, :night_end).find(service.active_service_promo_id) : "",
              promo_days: service.active_service_promo_id ? Promo.select(:id, :day_id, :morning_discount, :afternoon_discount, :night_discount).where(:service_promo_id => service.active_service_promo_id, :location_id => self.id) : "",
              has_session: service.has_sessions,
              sessions_amount: service.sessions_amount
            }
            services_array.push(service_info)
          end
        end
        bundles.each do |bundle|
          if bundle.service_category_id == category.id
            bundle_array = []
            bundle.service_bundles.each do |service_bundle|
              service_providers_array = []
              service_bundle.service.service_providers.where(active: true, online_booking: true, location_id: self.id).each do |service_provider|
                service_providers_array.push({id: service_provider.id, public_name: service_provider.public_name})
              end
              bundle_info = {
                id: service_bundle.service.id,
                name: service_bundle.service.name,
                price: service_bundle.service.show_price && service_bundle.price > 0 ? service_bundle.price : "",
                duration: service_bundle.service.duration,
                order: service_bundle.order,
                service_providers: service_providers_array
              }
              bundle_array.push(bundle_info)
            end
            service_info = {
              id: bundle.id,
              name: bundle.name,
              price: bundle.show_price && bundle.price > 0 ? bundle.price : "",
              duration: bundle.services.sum(:duration),
              service_category_id: bundle.service_category_id,
              order: 0,
              bundled: true,
              bundle: bundle_array,
              description: bundle.description,
              service_providers: [],
              promo_active: false,
              promo_hours: "",
              promo_days: "",
              has_session: false,
              sessions_amount: 1
            }
            services_array.push(service_info)
          end
        end
        service_hash = {
          :id => category.id,
          :category => category.name,
          :services => services_array
        }
        if services_array.count > 0
        categorized_services.push(service_hash)
      end
    end

    return categorized_services

    # service_providers = self.service_providers

    # services_ids = Array.new
    # services = Array.new
    # categories = Array.new
    # service_providers.each do |sp|
    # 	sp.services.where(active: true).each do |s|
    # 		services_ids.push(s.id)
    # 		services.push(s)
    # 		if(!categories.include?(s.service_category))
    # 			categories.push(s.service_category)
    # 		end
    # 	end
    # end

    # return categories

  end

	def categories
		# def location_categorized_services
	 #    location_resources = Location.find(params[:location]).resource_locations.pluck(:resource_id)
	 #    service_providers = ServiceProvider.where(location_id: params[:location])

	 #    categories = ServiceCategory.where(:company_id => Location.find(params[:location]).company_id).order(order: :asc)
	 #    services = Service.where(:active => true, :id => ServiceStaff.where(service_provider_id: service_providers.pluck(:id)).pluck(:service_id)).order(order: :asc)
	 #    service_resources_unavailable = ServiceResource.where(service_id: services)
	 #    if location_resources.any?
	 #      if location_resources.length > 1
	 #        service_resources_unavailable = service_resources_unavailable.where('resource_id NOT IN (?)', location_resources)
	 #      else
	 #        service_resources_unavailable = service_resources_unavailable.where('resource_id <> ?', location_resources)
	 #      end
	 #    end
	 #    if service_resources_unavailable.any?
	 #      if service_resources_unavailable.length > 1
	 #        services = services.where('services.id NOT IN (?)', service_resources_unavailable.pluck(:service_id))
	 #      else
	 #        services = services.where('id <> ?', service_resources_unavailable.pluck(:service_id))
	 #      end
	 #    end

	 #    categorized_services = Array.new
	 #    categories.each do |category|
	 #      services_array = Array.new
	 #      services.each do |service|
	 #        if service.service_category_id == category.id
	 #          serviceJSON = service.attributes.merge({'name_with_small_outcall' => service.name_with_small_outcall })
	 #          services_array.push(serviceJSON)
	 #        end
	 #      end
	 #      service_hash = {
	 #        :id => category.id,
	 #        :category => category.name,
	 #        :services => services_array
	 #      }
	 #      categorized_services.push(service_hash)
	 #    end

	 #    render :json => categorized_services
	 #  end


	 	# categories = self.service_providers.services.where(:active => true).pluck('service_category_id')
	 	# categories = ServiceCategory.where(:service_id => Service.where(:active => true, :id => ServiceProvider.where(:location_id => loc.id)))
	 	# categories = .service_providers.join(:service).where(:active => true).pluck('service_category_id')

	    service_providers = self.service_providers

	    services_ids = Array.new
	    services = Array.new
	    categories = Array.new
	    service_providers.each do |sp|
	     	sp.services.where(active: true).each do |s|
	     		services_ids.push(s.id)
	     		services.push(s)
	     		if(!categories.include?(s.service_category))
	     			categories.push(s.service_category)
	     		end
	    	end
	    end

	    return categories
	end

	def get_web_address
		return self.company.company_countries.find_by(country_id: self.country_id).web_address
	end

	def get_locale
		return self.country.locale
	end

	def opened_days_zero_index
		opened_days = []
		self.location_times.each do |location_time|
			if !opened_days.include? (location_time.day_id % 7)
				opened_days.push(location_time.day_id % 7)
			end
		end
		return opened_days
	end

	def closed_days_zero_index
		closed_days = [0,1,2,3,4,5,6]
		self.location_times.each do |location_time|
			if closed_days.include? (location_time.day_id % 7)
				closed_days.delete(location_time.day_id % 7)
			end
		end
		return closed_days
	end

	def self.stock_reminders

		now = DateTime.now
		week_locations = []
		month_locations = []

		#Check for locations that should be reminded today by week
		week_locations = Location.where(id: StockAlarmSetting.where(:periodic_send => true, :monthly => false, :week_day => now.cwday).pluck(:location_id))

		if (now + 1.days).mday == 1
			month_locations = Location.where(id: StockAlarmSetting.where(:periodic_send => true, :monthly => true).where('month_day >= ?', now.mday).pluck(:location_id))
		else
			month_locations = Location.where(id: StockAlarmSetting.where(:periodic_send => true, :monthly => true, :month_day => now.mday).pluck(:location_id))
		end

		locations = week_locations + month_locations

		locations.each do |location|

			location_products = []

			location.location_products.where.not(product_id: nil).where('product_id > 0').each do |location_product|
				if location_product.check_stock_for_reminder
					if !location_product.product.nil?
						location_products << location_product
					end
				end
			end

			if location_products.count > 0
				#Send reminder
        location.sendings.build(method: 'reminder_stock').save
			end

		end

	end

	def services_top4
		services = Service.where(active: true, online_booking: true).joins(:bookings).where('bookings.location_id = ?', self.id).group("services.id").limit(4)
		if services.to_a.count < 4
			top4 = Service.where(active: true, online_booking: true, id: ServiceStaff.where(service_provider_id: self.service_providers.pluck(:id)).pluck(:service_id)).select("services.id, services.name, services.duration, services.price, services.show_price").order(:order).limit(4)
		else
			top4 = Service.where(active: true, online_booking: true).select("services.id, services.name, services.duration, services.price, services.show_price, count(bookings.id) AS bookings_count").joins(:bookings).where('bookings.location_id = ?', self.id).group("services.id").order("bookings_count DESC").limit(4)
		end

		top4 = top4.as_json

		top4.each do |service|
			if service["show_price"] == false || service["price"] == 0
				service["price"] = nil
			end
		end

		return top4
	end

  def short_address
    location_address = LocationAddress.new read_attribute(:address)
    "#{location_address.route} #{location_address.street_number}, #{location_address.district}"
  end

  def long_address
    location_address = LocationAddress.new read_attribute(:address)
    "#{location_address.route} #{location_address.street_number}, #{location_address.district}, #{location_address.city}, #{location_address.country}"
  end

  def full_address
    location_address = LocationAddress.new read_attribute(:address)
    address = "#{location_address.route} #{location_address.street_number}, #{location_address.district}, #{location_address.administrative_area}, #{location_address.city}, #{location_address.region}, #{location_address.country}"
    address.length <= 11 ? "" : address
  end

  def short_address_with_second_address
    if self.second_address.present?
      "#{self.short_address} - #{self.second_address}"
    else
      "#{self.short_address}"
    end
  end

  def long_address_with_second_address
    if self.second_address.present?
      "#{self.long_address} - #{self.second_address}"
    else
      "#{self.long_address}"
    end
  end

  def full_address_with_second_address
    if self.second_address.present?
      "#{self.full_address} - #{self.second_address}"
    else
      "#{self.full_address}"
    end
  end

end

