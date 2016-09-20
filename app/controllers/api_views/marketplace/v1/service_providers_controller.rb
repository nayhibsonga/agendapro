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
            if local.location_open_days.where('start_time >= ? AND start_time <= ?', date.beginning_of_day.change(:format => "+0000"), date.end_of_day.change(:format => "+0000")).count == 0
              proceed = false
            end
          end

          start_date = date.to_datetime.beginning_of_day
          if loc_close.nil?
            if local.location_open_days.where('start_time >= ? AND start_time <= ?', date.beginning_of_day.change(:format => "+0000"), date.end_of_day.change(:format => "+0000")).count == 0
              proceed = false
            end
          else
            end_date = date.to_datetime.end_of_day
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