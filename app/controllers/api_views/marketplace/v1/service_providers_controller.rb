module ApiViews
  module Marketplace
    module V1
      class ServiceProvidersController < V1Controller

        def available_hours
          parser = PostgresParser.new

          week_days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
          require 'date'

          local = Location.find(params[:local])
          company_setting = local.company.company_setting
          cancelled_id = Status.find_by(name: 'Cancelado').id
          serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
          now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
          session_booking = nil

          if params[:session_booking_id] && params[:session_booking_id] != ""
            session_booking = SessionBooking.find(params[:session_booking_id])
          end

          if params[:date] && params[:date] != ""
            current_date = params[:date]
          else
            current_date = DateTime.now.to_date.to_s
          end

          weekDate = Date.strptime(current_date, '%Y-%m-%d')

          #logger.debug "current_date: " + current_date.to_s
          #logger.debug "weekDate: " + weekDate.to_s

          if params[:date] and params[:date] != ""
            if params[:date].to_datetime > now
              now = params[:date].to_datetime
            end
          end

          #logger.debug "now: " + now.to_s

          days_ids = [1,2,3,4,5,6,7]
          index = days_ids.find_index(now.cwday)
          ordered_days = days_ids[index, days_ids.length] + days_ids[0, index]

          day_positive_gaps = [0,0,0,0,0,0,0]

          @days_count = 0
          @week_blocks = []
          @days_row = []

          @morning_hours = []
          @afternoon_hours = []
          @night_hours = []

          book_index = 0
          book_summaries = []

          total_hours_array = []

          loop_times = 0

          max_time_diff = 0

          #Save first service and it's providers for later use

          first_service = Service.find(serviceStaff[0][:service])
          first_providers = []
          first_providers_ids = []
          if serviceStaff[0][:provider] != "0"
            first_providers << ServiceProvider.find(serviceStaff[0][:provider])
            first_providers_ids << ServiceProvider.find(serviceStaff[0][:provider]).id
          else

            first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(:order, :public_name)
            first_providers_ids = first_providers.pluck(:id)

            if first_providers.count == 0
              first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true).order(:order, :public_name)
              first_providers_ids = first_providers.pluck(:id)
            end

          end

          #Look for services and providers and save them for later use.
          #Also, save total services duration

          total_services_duration = 0

          #False if last tried block allocation failed.
          #Used for searching gaps. They should be looked for only if last block culd be allocated,
          #because if not, then there isn't anyway that coming back in time cause correct allocation.
          last_check = false

          #Checks if the block being allocated is from a gap
          is_gap_hour = false

          #Holds current_gap to sum a day's total gap and adjust calendar's height
          current_gap = 0

          services_arr = []
          bundles_arr = []
          providers_arr = []
          services = []

          for i in 0..serviceStaff.length-1
            services_arr[i] = serviceStaff[i][:service].to_i
            services << Service.find(services_arr[i])
            bundles_arr[i] = serviceStaff[i][:bundle_id].nil? ? 0 : serviceStaff[i][:bundle_id].to_i
            providers_arr[i] = serviceStaff[i][:provider].to_i
          end

          db_hours = []
          pg_hours = []
          company_id = local.company_id

          booking_leap = 0
          if providers_arr.count > 1
            booking_leap = company_setting.booking_leap;
          else
            if providers_arr.count > 0
              if providers_arr[0].to_i == 0
                booking_leap = company_setting.booking_leap;
              else
                booking_leap = ServiceProvider.find(providers_arr[0]).booking_leap
              end
            end
          end

          date = weekDate

          hours_array = []

          day = date.cwday
          dtp = local.location_times.where(day_id: day).order(:open).first
          loc_close = local.location_times.where(day_id: day).order(:close).last

          proceed = true

          if dtp.nil?
            proceed = false
          end

          start_date = date.to_datetime.beginning_of_day
          if loc_close.nil?
            proceed = false
          else
            end_date = DateTime.new(start_date.year, start_date.mon, start_date.mday, loc_close.close.hour, loc_close.close.min)
          end

          if proceed
            ActiveRecord::Base.connection.execute("SELECT * FROM available_hours(#{company_id}, #{local.id}, ARRAY#{providers_arr}, ARRAY#{services_arr}, ARRAY#{bundles_arr}, '#{start_date}', '#{end_date}', false, ARRAY#{first_providers_ids})").each do |row|
              db_hours = parser.parse_pg_array(row["hour_array"])
              db_gap = row["positive_gap"].to_i
              day_positive_gaps[day - 1] = db_gap
              ###################
              ## Hour creation ##
              ###################


              #Create bookings array
              #If too slow, adapt views
              #Create
              bookings = []
              db_hours.each_with_index do |db_hour, index|
                pg_hour = parser.parse_pg_array(db_hour)

                #pg_hour array definitions
                # 0: start_datetime
                # 1: end_datetime
                # 2: provider_id
                # 3: provider_name
                # 4: price
                # 5: has_time_discount
                # 6: time_discount
                # 7: has_treatment_discount
                # 8: treatment_discount
                # 9: service_promo_id
                # 10: treatment_promo_id

                provider_lock = false
                if pg_hour[2].to_i != 0
                  provider_lock = true
                end

                book_sessions_amount = 0
                if services[index].has_sessions && services[index].sessions_amount > 0
                  book_sessions_amount = services[index].sessions_amount
                end

                bookings << {
                  :service => services[index].id,
                  :provider => pg_hour[2].to_i,
                  :start => pg_hour[0].to_datetime,
                  :end => pg_hour[1].to_datetime,
                  :service_name => services[index].name,
                  :provider_name => pg_hour[3],
                  :provider_lock => provider_lock,
                  :provider_id => pg_hour[2].to_i,
                  :price => services[index].price,
                  :online_payable => services[index].online_payable,
                  :has_discount => services[index].has_discount,
                  :discount => services[index].discount,
                  :show_price => services[index].show_price && (bundles_arr[index] == 0),
                  :has_time_discount => pg_hour[5] == "t" ? true : false,
                  :time_discount => pg_hour[6].to_f,
                  :has_treatment_discount => pg_hour[7] == "t" ? true : false,
                  :treatment_discount => pg_hour[8].to_f,
                  :service_promo_id => pg_hour[9].present? ? pg_hour[9].to_i : "0",
                  :treatment_promo_id => pg_hour[10].present? ? pg_hour[10].to_i : "0",
                  :has_sessions => services[index].has_sessions,
                  :sessions_amount => book_sessions_amount,
                  :must_be_paid_online => services[index].must_be_paid_online,
                  :bundled => bundles_arr[index] != 0,
                  :bundle_id => (bundles_arr[index] != 0) ? bundles_arr[index] : nil
                }


              end
                

                

              #Create hour and append to hours_array
              has_time_discount = false
              has_treatment_discount = false
              bookings_group_discount = 0
              bookings_group_total_price = 0
              bookings_group_computed_price = 0

              if bookings.first[:has_sessions]
                if (bookings.first[:has_treatment_discount] && bookings.first[:treatment_discount] > 0) || (bookings.first[:has_discount] && bookings.first[:discount] > 0)
                  has_treatment_discount = true
                  if bookings.first[:has_treatment_discount] && !bookings.first[:has_discount]
                    bookings_group_discount = bookings.first[:treatment_discount]
                  elsif !bookings.first[:has_treatment_discount] && bookings.first[:has_discount]
                    bookings_group_discount = bookings.first[:discount]
                  else
                    if bookings.first[:treatment_discount] > bookings.first[:discount]
                      bookings_group_discount = bookings.first[:treatment_discount]
                    else
                      bookings_group_discount = bookings.first[:discount]
                    end
                  end
                else
                  bookings_group_discount = 0
                end
                bookings_group_total_price = bookings.first[:price]
                bookings_group_computed_price = bookings_group_total_price.to_f*(100.0 - bookings_group_discount.to_f)/100.0
              else
                bookings.each do |b|
                  bookings_group_total_price = bookings_group_total_price + b[:price]
                  if (b[:has_time_discount] && b[:time_discount] > 0) || (b[:has_discount] && b[:discount] > 0)
                    has_time_discount = true
                    if b[:has_discount] && !b[:has_time_discount]
                      bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
                    elsif !b[:has_discount] && b[:has_time_discount]
                      bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
                    else
                      if b[:discount] > b[:time_discount]
                        bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
                      else
                        bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
                      end
                    end
                  else
                    bookings_group_computed_price = bookings_group_computed_price + b[:price]
                  end
                end
              end

              if (bookings_group_total_price != 0)
                bookings_group_discount = (100 - (bookings_group_computed_price/bookings_group_total_price)*100).round(1)
              end

              status = "hora-disponible"

              if has_time_discount || has_treatment_discount
                if session_booking.nil?
                  status = "hora-promocion"
                end
              end

              #logger.debug "Time diff: "
              #logger.debug bookings[bookings.length-1][:end].to_s
              #logger.debug bookings[0][:start].to_s
              #logger.debug ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f.to_s
              hour_time_diff = ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f

              if hour_time_diff > max_time_diff
                max_time_diff = hour_time_diff
              end

              curr_promo_discount = 0

              if bookings.length == 1
                if has_time_discount
                  curr_promo_discount = bookings[0][:time_discount]
                elsif has_treatment_discount
                  curr_promo_discount = bookings[0][:treatment_discount]
                end
              end

              paying_price = 0
              booking_price = 0
              paying_total_price = 0
              booking_total_price = 0
              hidden_price = false
              bookings.each do |booking_calcs|
                if booking_calcs[:show_price]
                  booking_price += booking_calcs[:price]
                  booking_total_price += booking_calcs[:price]
                else
                  hidden_price = true
                end
                if booking_calcs[:online_payable]
                  current_promo_discount = booking_calcs[:treatment_discount] > booking_calcs[:time_discount] ? booking_calcs[:treatment_discount] : booking_calcs[:time_discount]
                  booking_calcs_discount = booking_calcs[:discount] > current_promo_discount ? booking_calcs[:discount] : current_promo_discount
                  paying_price += booking_calcs[:price] * (100 - booking_calcs_discount) / 100
                  paying_total_price += booking_calcs[:price] * (100 - booking_calcs_discount) / 100
                else
                  if booking_calcs[:show_price]
                    paying_total_price += booking_calcs[:price]
                  end
                end
              end

              if params[:mandatory_discount] == 'true' || params[:mandatory_discount] == true

                if has_time_discount || has_treatment_discount


                  new_hour = {
                    index: book_index,
                    date: I18n.l(bookings[0][:start].to_date, format: :day_short),
                    full_date: I18n.l(bookings[0][:start].to_date, format: :day),
                    hour: I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs',
                    bookings: bookings,
                    status: status,
                    start_block: bookings[0][:start].strftime("%H:%M"),
                    end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
                    available_provider: bookings[0][:provider_name],
                    provider_id: bookings[0][:provider_id],
                    promo_discount: curr_promo_discount.to_s,
                    has_time_discount: has_time_discount,
                    has_treatment_discount: has_treatment_discount,
                    time_diff: hour_time_diff,
                    has_sessions: bookings[0][:has_sessions],
                    sessions_amount: bookings[0][:sessions_amount],
                    group_discount: bookings_group_discount.to_s,
                    show_pay: bookings.any? { |booking| booking[:online_payable] == true },
                    show_booking: !bookings.any? { |booking| booking[:must_be_paid_online] == true },
                    paying_price: paying_price,
                    booking_price: booking_price,
                    paying_total_price: paying_total_price,
                    booking_total_price: booking_total_price,
                    hidden_price: hidden_price
                  }

                  book_index = book_index + 1
                  book_summaries << new_hour

                  if !hours_array.include?(new_hour)

                    hours_array << new_hour
                    puts new_hour.inspect

                    if new_hour[:start_block] < company_setting.promo_time.afternoon_start.strftime("%H:%M")
                      @morning_hours << new_hour
                    elsif new_hour[:start_block] < company_setting.promo_time.night_start.strftime("%H:%M")
                      @afternoon_hours << new_hour
                    else
                      @night_hours << new_hour
                    end

                    total_hours_array << new_hour

                  end

                end

              else

                new_hour = {
                  index: book_index,
                  date: I18n.l(bookings[0][:start].to_date, format: :day_short),
                  full_date: I18n.l(bookings[0][:start].to_date, format: :day),
                  hour: I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs',
                  bookings: bookings,
                  status: status,
                  start_block: bookings[0][:start].strftime("%H:%M"),
                  end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
                  available_provider: bookings[0][:provider_name],
                  provider_id: bookings[0][:provider_id],
                  promo_discount: curr_promo_discount.to_s,
                  has_time_discount: has_time_discount,
                  has_treatment_discount: has_treatment_discount,
                  has_sessions: bookings[0][:has_sessions],
                  sessions_amount: bookings[0][:sessions_amount],
                  time_diff: hour_time_diff,
                  group_discount: bookings_group_discount.to_s,
                  show_pay: bookings.any? { |booking| booking[:online_payable] == true },
                  show_booking: !bookings.any? { |booking| booking[:must_be_paid_online] == true },
                  paying_price: paying_price,
                  booking_price: booking_price,
                  paying_total_price: paying_total_price,
                  booking_total_price: booking_total_price,
                  hidden_price: hidden_price
                }

                book_index = book_index + 1
                book_summaries << new_hour

                should_add = true

                # if !session_booking.nil?

                #   if !session_booking.service_promo_id.nil? && session_booking.max_discount != 0
                #     if new_hour[:group_discount].to_f < session_booking.max_discount.to_f
                #       should_add = false
                #     end
                #   end

                # end

                # if params[:edit] && status == 'hora-promocion'
                #   should_add = false
                # end

                if should_add
                  if !hours_array.include?(new_hour)

                    hours_array << new_hour
                    puts new_hour.inspect

                    if new_hour[:start_block] < company_setting.promo_time.afternoon_start.strftime("%H:%M")
                      @morning_hours << new_hour
                    elsif new_hour[:start_block] < company_setting.promo_time.night_start.strftime("%H:%M")
                      @afternoon_hours << new_hour
                    else
                      @night_hours << new_hour
                    end

                    total_hours_array << new_hour

                  end
                end

              end

              ###################
              ###     END     ###
              ###################

            end
          end

          @days_count += 1
          @week_blocks << { available_time: hours_array, formatted_date: date.strftime('%Y-%m-%d') }
          @days_row << { day_name: week_days[date.wday], day_number: date.strftime("%e")}

          render json: {morning_hours: @morning_hours, afternoon_hours: @afternoon_hours, night_hours: @night_hours, day_name: week_days[date.wday], day_number: date.strftime("%e"), formatted_date: date.strftime('%Y-%m-%d')}


        end


        # def available_hours

        #   week_days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
        #   require 'date'

        #   local = Location.find(params[:local])
        #   company_setting = local.company.company_setting
        #   cancelled_id = Status.find_by(name: 'Cancelado').id
        #   serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
        #   now = DateTime.new(DateTime.now.year, DateTime.now.mon, DateTime.now.mday, DateTime.now.hour, DateTime.now.min)
        #   session_booking = nil

        #   if params[:session_booking_id] && params[:session_booking_id] != ""
        #     session_booking = SessionBooking.find(params[:session_booking_id])
        #   end

        #   if params[:date] && params[:date] != ""
        #     current_date = params[:date]
        #   else
        #     current_date = DateTime.now.to_date.to_s
        #   end

        #   weekDate = Date.strptime(current_date, '%Y-%m-%d')

        #   # logger.debug "current_date: " + current_date.to_s
        #   # logger.debug "weekDate: " + weekDate.to_s

        #   if params[:date] and params[:date] != ""
        #     if params[:date].to_datetime > now
        #       now = params[:date].to_datetime
        #     end
        #   end

        #   #logger.debug "now: " + now.to_s

        #   days_ids = [1,2,3,4,5,6,7]
        #   index = days_ids.find_index(now.cwday)
        #   ordered_days = days_ids[index, days_ids.length] + days_ids[0, index]

        #   day_positive_gaps = [0,0,0,0,0,0,0]

        #   @days_count = 0
        #   @week_blocks = []
        #   @days_row = []

        #   @morning_hours = []
        #   @afternoon_hours = []
        #   @night_hours = []

        #   book_index = 0
        #   book_summaries = []

        #   total_hours_array = []

        #   loop_times = 0

        #   max_time_diff = 0

        #   #Save first service and it's providers for later use

        #   first_service = Service.find(serviceStaff[0][:service])
        #   first_providers = []
        #   if serviceStaff[0][:provider] != "0"
        #     first_providers << ServiceProvider.find(serviceStaff[0][:provider])
        #   else
        #     first_providers = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(order: :asc)
        #   end

        #   #Look for services and providers and save them for later use.
        #   #Also, save total services duration

        #   total_services_duration = 0

        #   #False if last tried block allocation failed.
        #   #Used for searching gaps. They should be looked for only if last block culd be allocated, 
        #   #because if not, then there isn't anyway that coming back in time cause correct allocation.
        #   last_check = false

        #   #Checks if the block being allocated is from a gap
        #   is_gap_hour = false

        #   #Holds current_gap to sum a day's total gap and adjust calendar's height
        #   current_gap = 0

        #   services_arr = []
        #   providers_arr = []
        #   for i in 0..serviceStaff.length-1
        #     services_arr[i] = Service.find(serviceStaff[i][:service])
        #     total_services_duration += services_arr[i].duration
        #     if serviceStaff[i][:provider] != "0"
        #       providers_arr[i] = []
        #       providers_arr[i] << ServiceProvider.find(serviceStaff[i][:provider])
        #     else
        #       providers_arr[i] = ServiceProvider.where(id: first_service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true)
        #     end
        #   end

        #   #providers_arr = []
        #   #for i

        #   after_date = DateTime.now + company_setting.after_booking.months

        #   date = weekDate

        #   day = date.cwday
        #   dtp = local.location_times.where(day_id: day).order(:open).first
        #   if dtp.nil?
        #     #logger.debug "Nil day " + day.to_s
        #     # next
        #   end

        #   dateTimePointer = dtp.open

        #   dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
        #   day_open_time = dateTimePointer

        #   dateTimePointerEnd = dateTimePointer


        #   if date > after_date
        #     # break
        #   end

        #   hours_array = []

        #   day_close = local.location_times.where(day_id: day).order(:close).first.close
        #   limit_date = DateTime.new(date.year, date.mon, date.mday, day_close.hour, day_close.min)

        #   while (dateTimePointer < limit_date)

        #     serviceStaffPos = 0
        #     bookings = []

        #     while serviceStaffPos < serviceStaff.length and (dateTimePointer < limit_date)

        #       #if !first_service.company.company_setting.allows_optimization
        #       #  if dateTimePointerEnd > dateTimePointer
        #       #    logger.debug "Entra acá"
        #       #    dateTimePointer += first_service.company.company_setting.calendar_duration.minutes
        #       #    next
        #       #  end
        #       #end

        #       service_valid = false
        #       #service = Service.find(serviceStaff[serviceStaffPos][:service])
        #       service = services_arr[serviceStaffPos]

        #       #Get providers min
        #       min_pt = ProviderTime.where(:service_provider_id => ServiceProvider.where(active: true, online_booking: true, :location_id => local.id, :id => ServiceStaff.where(:service_id => service.id).pluck(:service_provider_id)).pluck(:id)).where(day_id: day).order(:open).first

        #       # logger.debug "MIN PROVIDER TIME: " + min_pt.open.strftime("%H:%M")
        #       # logger.debug "DATE TIME POINTER: " + dateTimePointer.strftime("%H:%M")

        #       if !min_pt.nil? && min_pt.open.strftime("%H:%M") > dateTimePointer.strftime("%H:%M")
        #         #logger.debug "Changing dtp"
        #         dateTimePointer = min_pt.open
        #         dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
        #         day_open_time = dateTimePointer
        #       end

        #       #To deattach continous services, just delete the serviceStaffPos condition

        #       if serviceStaffPos == 0 && !first_service.company.company_setting.allows_optimization
        #         #Calculate offset
        #         offset_diff = (dateTimePointer-day_open_time)*24*60
        #         offset_rem = offset_diff % first_service.company.company_setting.calendar_duration
        #         if offset_rem != 0
        #           dateTimePointer = dateTimePointer + (first_service.company.company_setting.calendar_duration - offset_rem).minutes
        #         end
        #       end

        #       #Find next service block starting from dateTimePointer
        #       service_sum = service.duration.minutes

        #       minHour = now
        #       # logger.debug "min_hours: " + minHour.to_s
        #       if minHour <= DateTime.now
        #         minHour += company_setting.before_booking.hours
        #       end
        #       if dateTimePointer >= minHour
        #         service_valid = true
        #       end

        #       # logger.debug "min_hours: " + minHour.to_s

        #       # Hora dentro del horario del local

        #       #if service_valid
        #       #  service_valid = false
        #       #  for
        #       #end

        #       if service_valid
        #         service_valid = false
        #         local.location_times.where(day_id: dateTimePointer.cwday).each do |times|
        #           location_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.open.hour, times.open.min)
        #           location_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, times.close.hour, times.close.min)

        #           if location_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= location_close
        #             service_valid = true
        #             break
        #           end
        #         end
        #       end

        #       # Horario dentro del horario del provider
        #       if service_valid
        #         providers = []
        #         if serviceStaff[serviceStaffPos][:provider] != "0"
        #           #providers << ServiceProvider.find(serviceStaff[serviceStaffPos][:provider])
        #           providers = providers_arr[serviceStaffPos]
        #         else

        #           #Check if providers have same day open
        #           #If they do, choose the one with less ocupations to start with
        #           #If they don't, choose the one that starts earlier.
        #           if service.check_providers_day_times(dateTimePointer)
        #             #providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }

        #             providers = providers_arr[serviceStaffPos].order(order: :desc).sort_by {|service_provider| service_provider.provider_booking_day_occupation(dateTimePointer) }

        #           else
        #             #providers = ServiceProvider.where(id: service.service_providers.pluck(:id), location_id: local.id, active: true, online_booking: true).order(order: :asc).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }

        #             providers = providers_arr[serviceStaffPos].order(order: :asc).sort_by {|service_provider| service_provider.provider_booking_day_open(dateTimePointer) }
        #           end



        #         end

        #         providers.each do |provider|

        #           provider_min_pt = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first
        #           if !provider_min_pt.nil? && dateTimePointer.strftime("%H:%M") < provider_min_pt.open.strftime("%H:%M")
        #             dateTimePointer = provider_min_pt.open
        #             dateTimePointer = DateTime.new(date.year, date.mon, date.mday, dateTimePointer.hour, dateTimePointer.min)
        #             #dateTimePointer = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open.to_datetime
        #           end

        #           service_valid = false

        #           #Check directly on query instead of looping through

        #           provider.provider_times.where(day_id: dateTimePointer.cwday).each do |provider_time|
        #             provider_open = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.open.hour, provider_time.open.min)
        #             provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time.close.hour, provider_time.close.min)

        #             if provider_open <= dateTimePointer and (dateTimePointer + service.duration.minutes) <= provider_close
        #               service_valid = true
        #               break
        #             end
        #           end

        #           # Provider breaks
        #           if service_valid

        #             if provider.provider_breaks.where.not('(provider_breaks.end <= ? or ? <= provider_breaks.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
        #               service_valid = false
        #             end

        #             #provider.provider_breaks.each do |provider_break|
        #             #  if !(provider_break.end.to_datetime <= dateTimePointer || (dateTimePointer + service.duration.minutes) <= provider_break.start.to_datetime)
        #             #    service_valid = false
        #             #    break
        #             #  end
        #             #end

        #           end

        #           # Cross Booking
        #           if service_valid

        #             if !service.group_service
        #               if Booking.where(service_provider_id: provider.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count > 0
        #                 service_valid = false
        #               end
        #             else
        #               if Booking.where(service_provider_id: provider.id, service_id: service.id).where.not(:status_id => cancelled_id).where('is_session = false or (is_session = true and is_session_booked = true)').where.not('(bookings.end <= ? or ? <= bookings.start)', dateTimePointer, dateTimePointer + service.duration.minutes).count >= service.capacity
        #                 service_valid = false
        #               end
        #             end


        #             # Booking.where(service_provider_id: provider.id, start: dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |provider_booking|
        #             #   unless provider_booking.status_id == cancelled_id
        #             #     pointerEnd = dateTimePointer+service.duration.minutes
        #             #     if !(pointerEnd <= provider_booking.start.to_datetime || provider_booking.end.to_datetime <= dateTimePointer)
        #             #       if !service.group_service || service.id != provider_booking.service_id
        #             #         if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
        #             #           service_valid = false
        #             #           break
        #             #         end
        #             #       elsif service.group_service && service.id == provider_booking.service_id && provider.bookings.where(service_id: service.id, start: dateTimePointer).where.not(status_id: Status.find_by_name('Cancelado')).count >= service.capacity
        #             #         if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
        #             #           service_valid = false
        #             #           break
        #             #         end
        #             #       end
        #             #     else
        #             #       #if !provider_booking.is_session || (provider_booking.is_session && provider_booking.is_session_booked)
        #             #       #  service_valid = false
        #             #       #end
        #             #     end
        #             #   end
        #             # end


        #           end

        #           # Recursos
        #           if service_valid and service.resources.count > 0
        #             service.resources.each do |resource|
        #               if !local.resource_locations.pluck(:resource_id).include?(resource.id)
        #                 service_valid = false
        #                 break
        #               end
        #               used_resource = 0
        #               group_services = []
        #               pointerEnd = dateTimePointer+service.duration.minutes
        #               local.bookings.where(:start => dateTimePointer.to_time.beginning_of_day..dateTimePointer.to_time.end_of_day).each do |location_booking|
        #                 if location_booking.status_id != cancelled_id && !(pointerEnd <= location_booking.start.to_datetime || location_booking.end.to_datetime <= dateTimePointer)
        #                   if location_booking.service.resources.include?(resource)
        #                     if !location_booking.service.group_service
        #                       used_resource += 1
        #                     else
        #                       if location_booking.service != service || location_booking.service_provider != provider
        #                         group_services.push(location_booking.service_provider.id)
        #                       end
        #                     end
        #                   end
        #                 end
        #               end
        #               if group_services.uniq.count + used_resource >= ResourceLocation.where(resource_id: resource.id, location_id: local.id).first.quantity
        #                 service_valid = false
        #                 break
        #               end
        #             end
        #           end

        #           if service_valid

        #             book_sessions_amount = 0
        #             if service.has_sessions
        #               book_sessions_amount = service.sessions_amount
        #             end

        #             bookings << {
        #               :service => service.id,
        #               :provider => provider.id,
        #               :start => dateTimePointer,
        #               :end => dateTimePointer + service.duration.minutes,
        #               :service_name => service.name,
        #               :provider_name => provider.public_name,
        #               :provider_lock => serviceStaff[serviceStaffPos][:provider] != "0",
        #               :provider_id => provider.id,
        #               :price => service.price,
        #               :online_payable => service.online_payable,
        #               :has_discount => service.has_discount,
        #               :discount => service.discount,
        #               :show_price => service.show_price,
        #               :has_time_discount => service.has_time_discount,
        #               :has_sessions => service.has_sessions,
        #               :sessions_amount => book_sessions_amount,
        #               :must_be_paid_online => service.must_be_paid_online
        #             }

        #             if !service.online_payable || !service.company.company_setting.online_payment_capable
        #               bookings.last[:has_discount] = false
        #               bookings.last[:has_time_discount] = false
        #               bookings.last[:discount] = 0
        #               bookings.last[:time_discount] = 0
        #               bookings.last[:has_treatment_discount] = false
        #               bookings.last[:treatment_discount_discount] = 0
        #             elsif !service.company.company_setting.promo_offerer_capable
        #               bookings.last[:has_time_discount] = false
        #               bookings.last[:time_discount] = 0
        #               bookings.last[:has_treatment_discount] = false
        #               bookings.last[:treatment_discount_discount] = 0
        #             end

        #             if !service.has_sessions

        #               bookings.last[:has_treatment_discount] = false
        #               bookings.last[:treatment_discount] = 0

        #               if service.has_time_discount && service.online_payable && service.company.company_setting.online_payment_capable && service.company.company_setting.promo_offerer_capable && service.time_promo_active

        #                 promo = Promo.where(:day_id => date.cwday, :service_promo_id => service.active_service_promo_id, :location_id => local.id).first

        #                 if !promo.nil?

        #                   service_promo = ServicePromo.find(service.active_service_promo_id)

        #                   #Check if there is a limit for bookings, and if there are any left
        #                   if service_promo.max_bookings > 0 || !service_promo.limit_booking

        #                     #Check if the promo is still active, and if the booking ends before the limit date

        #                     if bookings.last[:end].to_datetime < service_promo.book_limit_date && DateTime.now < service_promo.finish_date

        #                       if !(service_promo.morning_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.morning_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

        #                         bookings.last[:time_discount] = promo.morning_discount

        #                       elsif !(service_promo.afternoon_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.afternoon_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

        #                         bookings.last[:time_discount] = promo.afternoon_discount

        #                       elsif !(service_promo.night_start.strftime("%H:%M") >= bookings.last[:end].strftime("%H:%M") || service_promo.night_end.strftime("%H:%M") <= bookings.last[:start].strftime("%H:%M"))

        #                         bookings.last[:time_discount] = promo.night_discount

        #                       else

        #                         bookings.last[:time_discount] = 0

        #                       end
        #                     else
        #                       bookings.last[:time_discount] = 0
        #                     end
        #                   else
        #                     bookings.last[:time_discount] = 0
        #                   end

        #                 else

        #                   bookings.last[:time_discount] = 0

        #                 end

        #               else

        #                 bookings.last[:has_time_discount] = false
        #                 bookings.last[:time_discount] = 0

        #               end
        #             else

        #               bookings.last[:has_time_discount] = false
        #               bookings.last[:time_discount] = 0

        #               #Check treatment promo
        #               if service.has_treatment_promo && service.online_payable && service.company.company_setting.online_payment_capable && service.company.company_setting.promo_offerer_capable && service.time_promo_active

        #                 if !service.active_treatment_promo.nil?
        #                   if TreatmentPromoLocation.where(treatment_promo_id: service.active_treatment_promo_id, location_id: local.id).count > 0

        #                     if service.active_treatment_promo.max_bookings > 0

        #                       if !service.active_treatment_promo.limit_booking || (service.active_treatment_promo.finish_date > bookings.last[:start])
        #                         bookings.last[:has_treatment_discount] = true
        #                         bookings.last[:treatment_discount] = service.active_treatment_promo.discount
        #                       else
        #                         bookings.last[:has_treatment_discount] = false
        #                         bookings.last[:treatment_discount] = 0
        #                       end

        #                     else
        #                       bookings.last[:has_treatment_discount] = false
        #                       bookings.last[:treatment_discount] = 0
        #                     end

        #                   else
        #                     bookings.last[:has_treatment_discount] = false
        #                     bookings.last[:treatment_discount] = 0
        #                   end
        #                 else
        #                   bookings.last[:has_treatment_discount] = false
        #                   bookings.last[:treatment_discount] = 0
        #                 end

        #               else
        #                 bookings.last[:has_treatment_discount] = false
        #                 bookings.last[:treatment_discount] = 0
        #               end

        #             end

        #             #Check for active promos (regular or treatment)

        #             if service.active_service_promo_id.nil?
        #               bookings.last[:service_promo_id] = "0"
        #             else
        #               bookings.last[:service_promo_id] = service.active_service_promo_id
        #             end

        #             if service.active_treatment_promo_id.nil?
        #               bookings.last[:treatment_promo_id] = "0"
        #             else
        #               bookings.last[:treatment_promo_id] = service.active_treatment_promo_id
        #             end

        #             serviceStaffPos += 1

        #             if first_service.company.company_setting.allows_optimization
        #               if dateTimePointer < provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
        #                 dateTimePointer = provider.provider_times.where(day_id: dateTimePointer.cwday).order('open asc').first.open
        #               else
        #                 dateTimePointer += service.duration.minutes
        #               end
        #             else
        #               dateTimePointer = dateTimePointer + service.duration.minutes
        #             end

        #             if serviceStaffPos == serviceStaff.count
        #               last_check = true

        #               #Sum to gap_hours the gap_amount and reset gap flag.
        #               if is_gap_hour
        #                 day_positive_gaps[day-1] += (total_services_duration - current_gap)
        #                 is_gap_hour = false
        #                 current_gap = 0
        #               end
        #             end

        #             break
        #           end
        #         end
        #       end

        #       # puts service_valid

        #       if !service_valid


        #         #Reset gap_hour
        #         is_gap_hour = false

        #         #First, check if there's a gap. If so, back dateTimePointer to (blocking_start - total_duration)
        #         #This way, you can give two options when there are gaps.

        #         #logger.debug "DTP starting not valid: " + dateTimePointer.to_s
        #         #logger.debug "Last Check: " + last_check.to_s

        #         #Assume there is no gap
        #         time_gap = 0

        #         if first_service.company.company_setting.allows_optimization && last_check

        #           if first_providers.count > 1

        #             first_providers.each do |first_provider|

        #               book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

        #               break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

        #               provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

        #               if !provider_time_gap.nil?

        #                 provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

        #                 if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
        #                   gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
        #                   #logger.debug "Enters provider_close and gap is " + gap_diff.to_s
        #                   #logger.debug "Provider close: " + provider_close.to_s
        #                   if gap_diff > time_gap
        #                     time_gap = gap_diff
        #                   end
        #                 end

        #               end

        #               if book_gaps.count > 0
        #                 gap_diff = (book_gaps.first.start - dateTimePointer)/60
        #                 #logger.debug "Enters bookings and gap is " + gap_diff.to_s
        #                 #logger.debug "Book start: " + book_gaps.first.start.to_s
        #                 if gap_diff != 0
        #                   if gap_diff > time_gap
        #                     time_gap = gap_diff
        #                   end
        #                 end
        #               end

        #               if break_gaps.count > 0
        #                 gap_diff = (break_gaps.first.start - dateTimePointer)/60
        #                 #logger.debug "Enters breaks and gap is " + gap_diff.to_s
        #                 #logger.debug "Break start: " + break_gaps.first.start.to_s
        #                 if gap_diff != 0
        #                   if gap_diff > time_gap
        #                     time_gap = gap_diff
        #                   end
        #                 end
        #               end

        #             end

        #           else

        #             #Get nearest blocking start and check the gap.
        #             #Blocking can come from provider time day end.

        #             first_provider = first_providers.first

        #             book_gaps = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.start asc')

        #             break_gaps = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.start asc')

        #             provider_time_gap = first_provider.provider_times.where(day_id: dateTimePointer.cwday).order('close asc').first

        #             if !provider_time_gap.nil?

        #               provider_close = DateTime.new(dateTimePointer.year, dateTimePointer.month, dateTimePointer.mday, provider_time_gap.close.hour, provider_time_gap.close.min)

        #               if dateTimePointer < provider_close && provider_close < (dateTimePointer + total_services_duration.minutes)
        #                 gap_diff = ((provider_close - dateTimePointer)*24*60).to_f
        #                 #logger.debug "Enters provider_close and gap is " + gap_diff.to_s
        #                 #logger.debug "Provider close: " + provider_close.to_s
        #                 if gap_diff > time_gap
        #                   time_gap = gap_diff
        #                 end
        #               end

        #             end

        #             if book_gaps.count > 0
        #               gap_diff = (book_gaps.first.start - dateTimePointer)/60
        #               #logger.debug "Enters bookings and gap is " + gap_diff.to_s
        #               #logger.debug "Book start: " + book_gaps.first.start.to_s
        #               if gap_diff != 0
        #                 if gap_diff > time_gap
        #                   time_gap = gap_diff
        #                 end
        #               end
        #             end

        #             if break_gaps.count > 0
        #               gap_diff = (break_gaps.first.start - dateTimePointer)/60
        #               #logger.debug "Enters breaks and gap is " + gap_diff.to_s
        #               #logger.debug "Break start: " + break_gaps.first.start.to_s
        #               if gap_diff != 0
        #                 if gap_diff > time_gap
        #                   time_gap = gap_diff
        #                 end
        #               end
        #             end

        #           end

        #         end

        #         #logger.debug "DTP for gap: " + dateTimePointer.to_s
        #         #logger.debug "GAP: " + time_gap.to_s

        #         #Check for providers' bookings and breaks that include current dateTimePointer
        #         #If any, jump to the nearest end
        #         #Else, it's gotta be a resource issue or dtp is outside providers' time, so just add service duration as always
        #         #Last part could be optimized to jump to the nearest open provider's time

        #         #Time check must be an overlap of (dtp - dtp+service_duration) with booking/break (start - end)

        #         smallest_diff = first_service.duration
        #         #logger.debug "Defined smallest_diff: " + smallest_diff.to_s


        #         #Only do this when there is no gap
        #         if first_service.company.company_setting.allows_optimization && time_gap == 0

        #           if first_providers.count > 1

        #             first_providers.each do |first_provider|

        #               #book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes)

        #               book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')
        #               # logger.debug "***"
        #               # logger.debug "***"
        #               # logger.debug "***"
        #               # logger.debug "DTP: " + dateTimePointer.to_s
        #               # logger.debug "Multi book_blockings: " + book_blockings.count.to_s
        #               # logger.debug "***"
        #               # logger.debug "***"
        #               # logger.debug "***"
        #               if book_blockings.count > 0

        #                 book_diff = (book_blockings.first.end - dateTimePointer)/60
        #                 if book_diff < smallest_diff
        #                   smallest_diff = book_diff
        #                   #logger.debug "smallest_diff1: " + smallest_diff.to_s
        #                 end
        #               else
        #                 break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')
        #                 # logger.debug "***"
        #                 # logger.debug "***"
        #                 # logger.debug "***"
        #                 # logger.debug "DTP: " + dateTimePointer.to_s
        #                 # logger.debug "Multi break_blockings: " + book_blockings.count.to_s
        #                 # logger.debug "***"
        #                 # logger.debug "***"
        #                 # logger.debug "***"
        #                 if break_blockings.count > 0
        #                   break_diff = (break_blockings.first.end - dateTimePointer)/60
        #                   if break_diff < smallest_diff
        #                     smallest_diff = break_diff
        #                     #logger.debug "smallest_diff2: " + smallest_diff.to_s
        #                   end
        #                 end
        #               end

        #             end

        #           else

        #             first_provider = first_providers.first

        #             book_blockings = first_provider.bookings.where.not('(bookings.end <= ? or bookings.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('bookings.end asc')
        #             # logger.debug "***"
        #             # logger.debug "***"
        #             # logger.debug "***"
        #             # logger.debug "DTP: " + dateTimePointer.to_s
        #             # logger.debug "Single book_blockings: " + book_blockings.count.to_s
        #             # logger.debug "***"
        #             # logger.debug "***"
        #             # logger.debug "***"
        #             if book_blockings.count > 0
        #               book_diff = (book_blockings.first.end - dateTimePointer)/60
        #               if book_diff < smallest_diff
        #                 smallest_diff = book_diff
        #                 #logger.debug "smallest_diff3: " + smallest_diff.to_s
        #               end
        #             else
        #               break_blockings = first_provider.provider_breaks.where.not('(provider_breaks.end <= ? or provider_breaks.start >= ?)', dateTimePointer, dateTimePointer + first_service.duration.minutes).order('provider_breaks.end asc')
        #                 # logger.debug "***"
        #                 # logger.debug "***"
        #                 # logger.debug "***"
        #                 # logger.debug "DTP: " + dateTimePointer.to_s
        #                 # logger.debug "Single break_blockings: " + book_blockings.count.to_s
        #                 # logger.debug "***"
        #                 # logger.debug "***"
        #                 # logger.debug "***"
        #               if break_blockings.count > 0
        #                 break_diff = (break_blockings.first.end - dateTimePointer)/60
        #                 if break_diff < smallest_diff
        #                   smallest_diff = break_diff
        #                   #logger.debug "smallest_diff4: " + smallest_diff.to_s
        #                 end
        #               end
        #             end

        #           end

        #           if smallest_diff == 0
        #             smallest_diff = first_service.duration
        #           end

        #         else

        #           smallest_diff = first_service.company.company_setting.calendar_duration

        #         end

        #         # logger.debug "####"
        #         # logger.debug "####"
        #         # logger.debug "####"
        #         # logger.debug "####"
        #         # logger.debug "OLD DTP: " + dateTimePointer.to_s
        #         # logger.debug "Current smallest_diff: " + smallest_diff.to_s

        #         if first_service.company.company_setting.allows_optimization && time_gap > 0
        #           dateTimePointer = (dateTimePointer + time_gap.minutes) - total_services_duration.minutes
        #           is_gap_hour = true
        #           current_gap = time_gap
        #         else
        #           current_gap = 0
        #           dateTimePointer += smallest_diff.minutes
        #         end

        #         # logger.debug "NEW DTP: " + dateTimePointer.to_s
        #         # logger.debug "####"
        #         # logger.debug "####"
        #         # logger.debug "####"
        #         # logger.debug "####"

        #         #dateTimePointer += service.duration.minutes
        #         serviceStaffPos = 0
        #         bookings = []

        #         last_check = false

        #       end
        #     end

        #     if bookings.length == serviceStaff.length and (dateTimePointer <=> now + company_setting.after_booking.month) == -1

        #       has_time_discount = false
        #       has_treatment_discount = false
        #       bookings_group_discount = 0
        #       bookings_group_total_price = 0
        #       bookings_group_computed_price = 0

        #       if bookings.first[:has_sessions]
        #         if (bookings.first[:has_treatment_discount] && bookings.first[:treatment_discount] > 0) || (bookings.first[:has_discount] && bookings.first[:discount] > 0)
        #           has_treatment_discount = true
        #           if bookings.first[:has_treatment_discount] && !bookings.first[:has_discount]
        #             bookings_group_discount = bookings.first[:treatment_discount]
        #           elsif !bookings.first[:has_treatment_discount] && bookings.first[:has_discount]
        #             bookings_group_discount = bookings.first[:discount]
        #           else
        #             if bookings.first[:treatment_discount] > bookings.first[:discount]
        #               bookings_group_discount = bookings.first[:treatment_discount]
        #             else
        #               bookings_group_discount = bookings.first[:discount]
        #             end
        #           end
        #         else
        #           bookings_group_discount = 0
        #         end
        #         bookings_group_total_price = bookings.first[:price]
        #         bookings_group_computed_price = bookings_group_total_price.to_f*(100.0 - bookings_group_discount.to_f)/100.0
        #       else
        #         bookings.each do |b|
        #           bookings_group_total_price = bookings_group_total_price + b[:price]
        #           if (b[:has_time_discount] && b[:time_discount] > 0) || (b[:has_discount] && b[:discount] > 0)
        #             has_time_discount = true
        #             if b[:has_discount] && !b[:has_time_discount]
        #               bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
        #             elsif !b[:has_discount] && b[:has_time_discount]
        #               bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
        #             else
        #               if b[:discount] > b[:time_discount]
        #                 bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:discount]) / 100)
        #               else
        #                 bookings_group_computed_price = bookings_group_computed_price + (b[:price] * (100-b[:time_discount]) / 100)
        #               end
        #             end
        #           else
        #             bookings_group_computed_price = bookings_group_computed_price + b[:price]
        #           end
        #         end
        #       end

        #       if (bookings_group_total_price != 0)
        #         bookings_group_discount = (100 - (bookings_group_computed_price/bookings_group_total_price)*100).round(1)
        #       end

        #       status = "hora-disponible"

        #       if has_time_discount || has_treatment_discount
        #         if session_booking.nil?
        #           status = "hora-promocion"
        #         end
        #       end

        #       # puts status

        #       #logger.debug "Time diff: "
        #       #logger.debug bookings[bookings.length-1][:end].to_s
        #       #logger.debug bookings[0][:start].to_s
        #       #logger.debug ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f.to_s
        #       hour_time_diff = ((bookings[bookings.length-1][:end] - bookings[0][:start])*24*60).to_f

        #       if hour_time_diff > max_time_diff
        #         max_time_diff = hour_time_diff
        #       end

        #       curr_promo_discount = 0

        #       if bookings.length == 1
        #         if has_time_discount
        #           curr_promo_discount = bookings[0][:time_discount]
        #         elsif has_treatment_discount
        #           curr_promo_discount = bookings[0][:treatment_discount]
        #         end
        #       end

        #       paying_price = 0
        #       booking_price = 0
        #       paying_total_price = 0
        #       booking_total_price = 0
        #       hidden_price = false
        #       bookings.each do |booking_calcs|
        #         if booking_calcs[:show_price]
        #           booking_price += booking_calcs[:price]
        #           booking_total_price += booking_calcs[:price]
        #         else
        #           hidden_price = true
        #         end
        #         if booking_calcs[:online_payable]
        #           current_promo_discount = booking_calcs[:treatment_discount] > booking_calcs[:time_discount] ? booking_calcs[:treatment_discount] : booking_calcs[:time_discount]
        #           booking_calcs_discount = booking_calcs[:discount] > current_promo_discount ? booking_calcs[:discount] : current_promo_discount
        #           paying_price += booking_calcs[:price] * (100 - booking_calcs_discount) / 100
        #           paying_total_price += booking_calcs[:price] * (100 - booking_calcs_discount) / 100
        #         else
        #           if booking_calcs[:show_price]
        #             paying_total_price += booking_calcs[:price]
        #           end
        #         end
        #       end

        #       if params[:mandatory_discount] == 'true' || params[:mandatory_discount] == true

        #         if has_time_discount || has_treatment_discount


        #           new_hour = {
        #             index: book_index,
        #             date: I18n.l(bookings[0][:start].to_date, format: :day_short),
        #             full_date: I18n.l(bookings[0][:start].to_date, format: :day),
        #             hour: I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs',
        #             bookings: bookings,
        #             status: status,
        #             start_block: bookings[0][:start].strftime("%H:%M"),
        #             end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
        #             available_provider: bookings[0][:provider_name],
        #             provider_id: bookings[0][:provider_id],
        #             promo_discount: curr_promo_discount.to_s,
        #             has_time_discount: has_time_discount,
        #             has_treatment_discount: has_treatment_discount,
        #             time_diff: hour_time_diff,
        #             has_sessions: bookings[0][:has_sessions],
        #             sessions_amount: bookings[0][:sessions_amount],
        #             group_discount: bookings_group_discount.to_s,
        #             show_pay: bookings.any? { |booking| booking[:online_payable] == true },
        #             show_booking: !bookings.any? { |booking| booking[:must_be_paid_online] == true },
        #             paying_price: paying_price,
        #             booking_price: booking_price,
        #             paying_total_price: paying_total_price,
        #             booking_total_price: booking_total_price,
        #             hidden_price: hidden_price
        #           }

        #           book_index = book_index + 1
        #           book_summaries << new_hour

        #           if !hours_array.include?(new_hour)

        #             hours_array << new_hour
        #             puts new_hour.inspect

        #             if new_hour[:start_block] < company_setting.promo_time.afternoon_start.strftime("%H:%M")
        #               @morning_hours << new_hour
        #             elsif new_hour[:start_block] < company_setting.promo_time.night_start.strftime("%H:%M")
        #               @afternoon_hours << new_hour
        #             else
        #               @night_hours << new_hour
        #             end

        #             total_hours_array << new_hour

        #           end

        #         end

        #       else

        #         new_hour = {
        #           index: book_index,
        #           date: I18n.l(bookings[0][:start].to_date, format: :day_short),
        #           full_date: I18n.l(bookings[0][:start].to_date, format: :day),
        #           hour: I18n.l(bookings[0][:start].to_datetime, format: :hour) + ' - ' + I18n.l(bookings[bookings.length - 1][:end].to_datetime, format: :hour) + ' Hrs',
        #           bookings: bookings,
        #           status: status,
        #           start_block: bookings[0][:start].strftime("%H:%M"),
        #           end_block: bookings[bookings.length-1][:end].strftime("%H:%M"),
        #           available_provider: bookings[0][:provider_name],
        #           provider_id: bookings[0][:provider_id],
        #           promo_discount: curr_promo_discount.to_s,
        #           has_time_discount: has_time_discount,
        #           has_treatment_discount: has_treatment_discount,
        #           has_sessions: bookings[0][:has_sessions],
        #           sessions_amount: bookings[0][:sessions_amount],
        #           time_diff: hour_time_diff,
        #           group_discount: bookings_group_discount.to_s,
        #           show_pay: bookings.any? { |booking| booking[:online_payable] == true },
        #           show_booking: !bookings.any? { |booking| booking[:must_be_paid_online] == true },
        #           paying_price: paying_price,
        #           booking_price: booking_price,
        #           paying_total_price: paying_total_price,
        #           booking_total_price: booking_total_price,
        #           hidden_price: hidden_price
        #         }

        #         book_index = book_index + 1
        #         book_summaries << new_hour

        #         should_add = true

        #         # if !session_booking.nil?

        #         #   if !session_booking.service_promo_id.nil? && session_booking.max_discount != 0
        #         #     if new_hour[:group_discount].to_f < session_booking.max_discount.to_f
        #         #       should_add = false
        #         #     end
        #         #   end

        #         # end

        #         # if params[:edit] && status == 'hora-promocion'
        #         #   should_add = false
        #         # end

        #         if should_add
        #           if !hours_array.include?(new_hour)

        #             hours_array << new_hour
        #             puts new_hour.inspect

        #             if new_hour[:start_block] < company_setting.promo_time.afternoon_start.strftime("%H:%M")
        #               @morning_hours << new_hour
        #             elsif new_hour[:start_block] < company_setting.promo_time.night_start.strftime("%H:%M")
        #               @afternoon_hours << new_hour
        #             else
        #               @night_hours << new_hour
        #             end

        #             total_hours_array << new_hour

        #           end
        #         end

        #       end

        #     end

        #   end

        #   @days_count += 1
        #   @week_blocks << { available_time: hours_array, formatted_date: date.strftime('%Y-%m-%d') }
        #   @days_row << { day_name: week_days[date.wday], day_number: date.strftime("%e")}

          

        #   render json: {morning_hours: @morning_hours, afternoon_hours: @afternoon_hours, night_hours: @night_hours, day_name: week_days[date.wday], day_number: date.strftime("%e"), formatted_date: date.strftime('%Y-%m-%d')}


        # end

        def available_days


          serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
            
          service_ids = []
          provider_ids = []
          puts ServiceStaff.inspect
          serviceStaff.each do |service_staff|
            if service_staff[:service].present? && service_staff[:provider].present?
              service_ids.push(service_staff[:service].to_i)
              provider_ids.push(service_staff[:provider].to_i)
            end
          end

          query = "SELECT * FROM check_days(#{params[:local]}, ARRAY#{provider_ids.inspect}, ARRAY#{service_ids.inspect}, '#{params[:start_date]}', '#{params[:end_date]}')"
          @results = ActiveRecord::Base.connection.execute(query)

          # # puts @results.inspect
          # @results.each do |result|
          #  puts result.inspect 
          # end
          # render json: {response: "Success"}, status: 200
        end

        def available_promo_days


          serviceStaff = JSON.parse(params[:serviceStaff], symbolize_names: true)
            
          service_ids = []
          provider_ids = []
          puts ServiceStaff.inspect
          serviceStaff.each do |service_staff|
            if service_staff[:service].present? && service_staff[:provider].present?
              service_ids.push(service_staff[:service].to_i)
              provider_ids.push(service_staff[:provider].to_i)
            end
          end

          query = "SELECT * FROM check_promo_days(#{params[:local]}, ARRAY#{provider_ids.inspect}, ARRAY#{service_ids.inspect}, '#{params[:start_date]}', '#{params[:end_date]}')"
          @results = ActiveRecord::Base.connection.execute(query)

          # # puts @results.inspect
          # @results.each do |result|
          #  puts result.inspect 
          # end
          # render json: {response: "Success"}, status: 200
        end

      end
    end
  end
end