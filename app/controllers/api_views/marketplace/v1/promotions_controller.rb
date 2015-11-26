module ApiViews::Marketplace
  module V1
    class PromotionsController < V1Controller
      def index
        country = Country.find(params[:country_id])
        @latitude = params[:latitude].blank? ? country.latitude : params[:latitude]
        @longitude = params[:longitude].blank? ? country.longitude : params[:longitude]
        @results = []

        # First, search services with promotions based on time of book (morning, afternoon, night)
        time_query = Location.where(company_id: Company.where(active: true, owned: true).where(id: CompanySetting.where(activate_search: true, activate_workflow: true, id: PromoTime.where(active: true).pluck(:company_setting_id)).pluck('company_id'))).where(active: true).where("sqrt((latitude - #{@latitude} )^2 + (longitude - #{@longitude})^2) < 0.25")
        query = time_query

        locs = Array.new
        ordered_locs = Array.new

        query.each do |location|
          dist_score = Math.sqrt((location.latitude - @latitude.to_f)**2 + (location.longitude - @longitude.to_f)**2)
          local = [location, dist_score]
          locs.push(local)
        end

        # Using first index of arr, then why define Array instead of variable?

        ordered_locs[0] = locs.sort_by{ |loc| loc[1]}

        @locations = Array.new
        @last_minute_results = Array.new

        ordered_locs.each do |arr|
          arr.each do |s|

            time_promo_services = []

            ServiceProvider.where(active: true, location_id: s[0]).each do |service_provider|
              time_promo_services = service_provider.services.with_time_promotions

              time_promo_services.each do |service|
                #Check it has stock
                if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
                  if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
                    promo_detail = [service, s[0]]
                    if @results.exclude?(promo_detail)
                      @results << promo_detail
                      #if !@locations.include?(s[0])
                      @locations << s[0]
                    end
                  end
                end
              end

            end

          end
        end
        @results
      end

      def preview
        country = Country.find(params[:country_id])

        @lat = country.latitude
        @lng = country.longitude

        if params[:latitude] &&  params[:latitude] != ""
          @lat = params[:latitude]
        end
        if params[:longitude] && params[:longitude] != ""
          @lng = params[:longitude]
        end


        lat = @lat
        long = @lng

        @latitude = @lat
        @longitude = @lng

        @results = Array.new

        # First, search services with promotions based on time of book (morning, afternoon, night)

        time_query = Location.where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true, id: PromoTime.where(:active => true).pluck(:company_setting_id)).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')

        query = time_query

        locs = Array.new
        ordered_locs = Array.new
        query.each do |location|
          dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
          local = [location, dist_score]
          locs.push(local)
        end
        ordered_locs[0] = locs.sort_by{ |loc| loc[1]}

        @results = Array.new
        @locations = Array.new
        @last_minute_results = Array.new

        ordered_locs.each do |arr|
          arr.each do |s|

            time_promo_services = []

            ServiceProvider.where(:active => true, :location_id => s[0]).each do |service_provider|
              time_promo_services = service_provider.services.with_time_promotions

              time_promo_services.each do |service|
                #Check it has stock
                if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
                  if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
                    promo_detail = [service, s[0]]
                    if !@results.include?(promo_detail)
                      @results << promo_detail
                      #if !@locations.include?(s[0])
                      @locations << s[0]
                    end
                  end
                end
              end
            end
          end
        end

        @results = @results.first(3)
      end

      def show
        @service = Service.find(params[:id])
        @location = Location.find(params[:location_id])
        @company = @location.company
        @booking_conditions = ''
        if @service.active_service_promo.limit_booking
          @booking_conditions += 'Quedan ' + @service.active_promo_left_bookings.to_s + ' reservas disponibles para esta promoción.'
          if @service.active_promo_left_bookings <= 20
            @booking_conditions += '¡Apúrate y reserva antes que se acaben!'
          end
        else
          @booking_conditions += 'Esta promoción no tiene límite de stock.'
        end
        @booking_dates = 'Esta promoción acaba el ' + I18n.l(@service.active_service_promo.finish_date.to_date) + ', y permite reservar horas hasta el ' + I18n.l(@service.active_service_promo.book_limit_date.to_date)
        @discounts = @service.get_time_promos(@location.id)
        @service_providers_array = []
        @service.service_providers.where(active: true, online_booking: true, location_id: @location.id).each do |service_provider|
          @service_providers_array.push({id: service_provider.id, public_name: service_provider.public_name})
        end

        #Check existance of promo
        if !@service.has_time_discount || @service.service_promos.nil? || @service.active_service_promo_id.nil?
          render json: { errors: "No existen promociones para el servicio buscado." }, status: 422
          return
        end

        #Check promo has stock
        if @service.active_service_promo.max_bookings < 1 && @service.active_service_promo.limit_booking
          render json: { errors: "No queda stock para la promoción buscada." }, status: 422
          return
        end

        #Check promo hasn't expired
        if DateTime.now > @service.active_service_promo.finish_date || DateTime.now > @service.active_service_promo.book_limit_date
          render json: { errors: "La promoción buscada ya expiró." }, status: 422
          return
        end
      end
    end
  end
end
