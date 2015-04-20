
class ProviderBreaksController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def provider_breaks
    start_date = DateTime.parse(params[:start])
    end_date = DateTime.parse(params[:end])
    provider_breaks = ProviderBreak.where(service_provider_id: params[:service_provider_id]).where('(provider_breaks.start,provider_breaks.end) overlaps (date ?,date ?)', end_date, start_date).order(:start)
    render :json => provider_breaks
  end

  def get_provider_break
    provider_break = ProviderBreak.find(params[:id])
    render :json => provider_break
  end

  def create_provider_break
    if params[:provider_break][:service_provider_id].to_i != 0
      if params[:provider_break][:repeat] == "never"
        @provider_break = ProviderBreak.new(:start => params[:provider_break][:start], :end => params[:provider_break][:end], :service_provider_id => params[:provider_break][:service_provider_id].to_i, :name => params[:provider_break][:name])
        respond_to do |format|
          if @provider_break.save
            @provider_break.warnings ? warnings = @provider_break.warnings.full_messages : warnings = []
            @break_json = {id: @provider_break.id, start: @provider_break.start, end: @provider_break.end, service_provider_id: @provider_break.service_provider_id, name: @provider_break.name, warnings: warnings}
            format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
            format.json { render :json => @break_json }
            format.js { }
          else
            format.html { render action: 'index' }
            format.json { render :json => { :errors => @provider_break.errors.full_messages }, :status => 422 }
            format.js { }
          end
        end
      else
        @break_json = Array.new
        @break_errors = Array.new

        status = true


        repeat_id = 0
        repeat_group = ProviderBreak.where.not(break_repeat_id: nil).order(:break_repeat_id).last
        if repeat_group.nil?
          repeat_id = 0
        else
          repeat_id = repeat_group.break_repeat_id + 1
        end

        #repeat_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
        first_start_date = params[:provider_break][:start].to_datetime
        first_end_date = params[:provider_break][:end].to_datetime
        if params[:provider_break][:repeat_option] == "times"
          times = 1
          if params[:provider_break][:times] != ""
            times = params[:provider_break][:times].to_i
          end
          for i in 0..times-1
            if params[:provider_break][:repeat] == "daily"
              start_date = first_start_date + i.days
              end_date = first_end_date + i.days
            elsif params[:provider_break][:repeat] == "weekly"
              start_date = first_start_date + i.weeks
              end_date = first_end_date + i.weeks
            elsif params[:provider_break][:repeat] == "monthly_date"
              start_date = first_start_date + i.months
              end_date = first_end_date + i.months
            elsif params[:provider_break][:repeat] == "monthly_day"
              start_date = first_start_date + i.months
              end_date = first_end_date + i.months

              #Get correct day
              diff = (start_date.wday-first_start_date.wday)%7
              
              if (start_date - diff.days).wday == first_start_date.wday
                start_date = start_date - diff.days
                end_date = end_date - diff.days
              else
                start_date = start_date + diff.days
                end_date = end_date + diff.days
              end

              #Get correct week
              if start_date.day/7 != first_start_date.day/7
                if start_date.day/7 < first_start_date.day/7
                  start_date = start_date + 1.weeks
                  end_date = end_date + 1.weeks
                else
                  start_date = start_date - 1.weeks
                  end_date = end_date - 1.weeks
                end
              end

            elsif params[:provider_break][:repeat] == "yearly"
              start_date = first_start_date + i.years
              end_date = first_end_date + i.years
            end               
            provider_break = ProviderBreak.new(:start => start_date, :end => end_date, :service_provider_id => params[:provider_break][:service_provider_id].to_i, :name => params[:provider_break][:name], :break_repeat_id => repeat_id)

            if provider_break.save
              provider_break.warnings ? warnings = provider_break.warnings.full_messages : warnings = []
              @break_json.push({id: provider_break.id, start: provider_break.start, end: provider_break.end, service_provider_id: provider_break.service_provider_id, name: provider_break.name, warnings: warnings})
              status = status && true
            else
              @break_errors.push(provider_break.errors.full_messages)
              status = status && false
            end

          end
        else


          start_date = first_start_date
          end_date = first_end_date
          final_date = params[:provider_break][:repeat_end].to_datetime

          i = 0

          while start_date < final_date

            if params[:provider_break][:repeat] == "daily"
              start_date = first_start_date + i.days
              end_date = first_end_date + i.days
            elsif params[:provider_break][:repeat] == "weekly"
              start_date = first_start_date + i.weeks
              end_date = first_end_date + i.weeks
            elsif params[:provider_break][:repeat] == "monthly_date"
              start_date = first_start_date + i.months
              end_date = first_end_date + i.months
            elsif params[:provider_break][:repeat] == "monthly_day"
              start_date = first_start_date + i.months
              end_date = first_end_date + i.months

              #Get correct day
              diff = (start_date.wday-first_start_date.wday)%7
              
              if (start_date - diff.days).wday == first_start_date.wday
                start_date = start_date - diff.days
                end_date = end_date - diff.days
              else
                start_date = start_date + diff.days
                end_date = end_date + diff.days
              end

              #Get correct week
              if start_date.day/7 != first_start_date.day/7
                if start_date.day/7 < first_start_date.day/7
                  start_date = start_date + 1.weeks
                  end_date = end_date + 1.weeks
                else
                  start_date = start_date - 1.weeks
                  end_date = end_date - 1.weeks
                end
              end
            elsif params[:provider_break][:repeat] == "yearly"
              start_date = first_start_date + i.years
              end_date = first_end_date + i.years
            end

            if start_date > final_date
              break
            end 

            provider_break = ProviderBreak.new(:start => start_date, :end => end_date, :service_provider_id => params[:provider_break][:service_provider_id].to_i, :name => params[:provider_break][:name], :break_repeat_id => repeat_id)

            if provider_break.save
              provider_break.warnings ? warnings = provider_break.warnings.full_messages : warnings = []
              @break_json.push({id: provider_break.id, start: provider_break.start, end: provider_break.end, service_provider_id: provider_break.service_provider_id, name: provider_break.name, warnings: warnings})
              status = status && true
            else
              @break_errors.push(provider_break.errors.full_messages)
              status = status && false
            end

            i = i+1

          end

        end

        respond_to do |format|
          if status
            format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
            format.json { render :json => @break_json }
            format.js { }
          else
            format.html { render action: 'index' }
            format.json { render :json => { :errors => @break_errors }, :status => 422 }
            format.js { }
          end
        end

      end
    else

      service_providers = ServiceProvider.where(location_id: provider_break_params[:local])
      break_group = ProviderBreak.where(service_provider_id: service_providers).where.not(break_group_id: nil).order(:break_group_id).last
      if break_group.nil?
        break_group = 0
      else
        break_group = break_group.break_group_id + 1
      end

      repeat_id = 0
      repeat_group = ProviderBreak.where.not(break_repeat_id: nil).order(:break_repeat_id).last
      if repeat_group.nil?
        repeat_id = 0
      else
        repeat_id = repeat_group.break_repeat_id + 1
      end

      @break_json = Array.new
      @break_errors = Array.new
      status = true


      if params[:provider_break][:repeat] != "never"
        service_providers.each do |provider|
          
          break_group_id = break_group
          
          #repeat_group = ProviderBreak.where.not(break_repeat_id: nil).order(:break_repeat_id).last

          #repeat_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
          first_start_date = params[:provider_break][:start].to_datetime
          first_end_date = params[:provider_break][:end].to_datetime
          if params[:provider_break][:repeat_option] == "times"
            times = params[:provider_break][:times].to_i
            for i in 0..times-1
              if params[:provider_break][:repeat] == "daily"
                start_date = first_start_date + i.days
                end_date = first_end_date + i.days
              elsif params[:provider_break][:repeat] == "weekly"
                start_date = first_start_date + i.weeks
                end_date = first_end_date + i.weeks
              elsif params[:provider_break][:repeat] == "monthly_date"
                start_date = first_start_date + i.months
                end_date = first_end_date + i.months
              elsif params[:provider_break][:repeat] == "monthly_day"
                start_date = first_start_date + i.months
                end_date = first_end_date + i.months

                #Get correct day
                diff = (start_date.wday-first_start_date.wday)%7
                
                if (start_date - diff.days).wday == first_start_date.wday
                  start_date = start_date - diff.days
                  end_date = end_date - diff.days
                else
                  start_date = start_date + diff.days
                  end_date = end_date + diff.days
                end

                #Get correct week
                if start_date.day/7 != first_start_date.day/7
                  if start_date.day/7 < first_start_date.day/7
                    start_date = start_date + 1.weeks
                    end_date = end_date + 1.weeks
                  else
                    start_date = start_date - 1.weeks
                    end_date = end_date - 1.weeks
                  end
                end
              elsif params[:provider_break][:repeat] == "yearly"
                start_date = first_start_date + i.years
                end_date = first_end_date + i.years
              end               
              provider_break = ProviderBreak.new(:start => start_date, :end => end_date, :service_provider_id => provider.id, :name => params[:provider_break][:name], :break_group_id => break_group_id, :break_repeat_id => repeat_id)

              if provider_break.save
                provider_break.warnings ? warnings = provider_break.warnings.full_messages : warnings = []
                @break_json.push({id: provider_break.id, start: provider_break.start, end: provider_break.end, service_provider_id: provider_break.service_provider_id, name: provider_break.name, warnings: warnings})
                status = status && true
              else
                @break_errors.push(provider_break.errors.full_messages)
                status = status && false
              end

            end
          else

            start_date = first_start_date
            end_date = first_end_date
            final_date = params[:provider_break][:repeat_end].to_datetime

            i = 0

            while start_date < final_date

              if params[:provider_break][:repeat] == "daily"
                start_date = first_start_date + i.days
                end_date = first_end_date + i.days
              elsif params[:provider_break][:repeat] == "weekly"
                start_date = first_start_date + i.weeks
                end_date = first_end_date + i.weeks
              elsif params[:provider_break][:repeat] == "monthly_date"
                start_date = first_start_date + i.months
                end_date = first_end_date + i.months
              elsif params[:provider_break][:repeat] == "monthly_day"
                start_date = first_start_date + i.months
                end_date = first_end_date + i.months

                #Get correct day
                diff = (start_date.wday-first_start_date.wday)%7
                
                if (start_date - diff.days).wday == first_start_date.wday
                  start_date = start_date - diff.days
                  end_date = end_date - diff.days
                else
                  start_date = start_date + diff.days
                  end_date = end_date + diff.days
                end

                #Get correct week
                if start_date.day/7 != first_start_date.day/7
                  if start_date.day/7 < first_start_date.day/7
                    start_date = start_date + 1.weeks
                    end_date = end_date + 1.weeks
                  else
                    start_date = start_date - 1.weeks
                    end_date = end_date - 1.weeks
                  end
                end
              elsif params[:provider_break][:repeat] == "yearly"
                start_date = first_start_date + i.years
                end_date = first_end_date + i.years
              end

              if start_date > final_date
                break
              end

              provider_break = ProviderBreak.new(:start => start_date, :end => end_date, :service_provider_id => provider.id, :name => params[:provider_break][:name], :break_group_id => break_group_id, :break_repeat_id => repeat_id)

              if provider_break.save
                provider_break.warnings ? warnings = provider_break.warnings.full_messages : warnings = []
                @break_json.push({id: provider_break.id, start: provider_break.start, end: provider_break.end, service_provider_id: provider_break.service_provider_id, name: provider_break.name, warnings: warnings})
                status = status && true
              else
                @break_errors.push(provider_break.errors.full_messages)
                status = status && false
              end

              i = i+1

            end

          end

        end
      else

        service_providers.each do |provider|
          
          break_group_id = break_group
          provider_break = ProviderBreak.new(:start => params[:provider_break][:start], :end => params[:provider_break][:end], :service_provider_id => provider.id, :name => params[:provider_break][:name], :break_group_id => break_group_id)

          if provider_break.save
            provider_break.warnings ? warnings = provider_break.warnings.full_messages : warnings = []
            @break_json.push({id: provider_break.id, start: provider_break.start, end: provider_break.end, service_provider_id: provider_break.service_provider_id, name: provider_break.name, warnings: warnings})
            status = status && true
          else
            @break_errors.push(provider_break.errors.full_messages)
            status = status && false
          end
        end

      end

      respond_to do |format|
        if status
          format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
          format.json { render :json => @break_json }
          format.js { }
        else
          format.html { render action: 'index' }
          format.json { render :json => { :errors => @break_errors }, :status => 422 }
          format.js { }
        end
      end
    end
  end


  #Edit only this one, take out from series.
  def update_provider_break
    #if provider_break_params[:service_provider_id].to_i != 0
      @provider_break = ProviderBreak.find(params[:id])
      respond_to do |format|
        break_params = provider_break_params.except(:local)
        break_params[:break_group_id] = nil
        @provider_break.service_provider_id = provider_break_params[:service_provider_id]
        @provider_break.break_group_id = nil
        @provider_break.name = provider_break_params[:name]
        @provider_break.start = provider_break_params[:start]
        @provider_break.end = provider_break_params[:end]
        @provider_break.break_repeat_id = nil
        if @provider_break.save

          @provider_break.warnings ? warnings = @provider_break.warnings.full_messages : warnings = []
          @break_json = {id: @provider_break.id, start: @provider_break.start, end: @provider_break.end, service_provider_id: @provider_break.service_provider_id, name: @provider_break.name, warnings: warnings}

          format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
          format.json { render :json => @break_json }
          format.js { }
        else
          format.html { render action: 'index' }
          format.json { render :json => { :errors => @provider_break.errors.full_messages }, :status => 422 }
          format.js { }
        end
      end
    # else
    #   break_group = ProviderBreak.find(params[:id]).break_group_id
    #   service_providers = ServiceProvider.where(location_id: provider_break_params[:local])
    #   @break_json = Array.new
    #   @break_errors = Array.new
    #   status = true
    #   if !break_group.nil?
    #     provider_breaks = ProviderBreak.where(service_provider_id: service_providers).where(break_group_id: break_group)
    #     provider_breaks.each do |breaks|
    #       break_params = provider_break_params.except(:local)
    #       break_params[:service_provider_id] = breaks.service_provider_id
    #       break_params[:break_group_id] = break_group

    #       breaks.break_group_id = break_group
    #       breaks.name = provider_break_params[:name]
    #       breaks.start = provider_break_params[:start]
    #       breaks.end = provider_break_params[:end]
    #       breaks.break_repeat_id = nil

    #       if breaks.save
    #         breaks.warnings ? warnings = breaks.warnings.full_messages : warnings = []
    #         @break_json.push({id: breaks.id, start: breaks.start, end: breaks.end, service_provider_id: breaks.service_provider_id, name: breaks.name, warnings: warnings})
    #         status = status && true
    #       else
    #         @break_errors.push(breaks.errors.full_messages)
    #         status = status && false
    #       end
    #     end
    #   else
    #     originalBreak = ProviderBreak.find(params[:id])
    #     break_group = ProviderBreak.where(service_provider_id: service_providers).where.not(break_group_id: nil).order(:break_group_id).last
    #     if break_group.nil?
    #       break_group = 0
    #     else
    #       break_group = break_group.break_group_id + 1
    #     end
    #     break_params = provider_break_params.except(:local)
    #     break_params[:service_provider_id] = originalBreak.service_provider_id
    #     break_params[:break_group_id] = break_group

    #     originalBreak.name = provider_break_params[:name]
    #     originalBreak.start = provider_break_params[:start]
    #     originalBreak.end = provider_break_params[:end]
    #     originalBreak.break_repeat_id = nil
    #     originalBreak.break_group_id = break_group

    #     # The provider with the break
    #     if originalBreak.save
    #       originalBreak.warnings ? warnings = originalBreak.warnings.full_messages : warnings = []
    #       @break_json.push({id: originalBreak.id, start: originalBreak.start, end: originalBreak.end, service_provider_id: originalBreak.service_provider_id, name: originalBreak.name, warnings: warnings})
    #       status = status && true
    #     else
    #       @break_errors.push(originalBreak.errors.full_messages)
    #       status = status && false
    #     end
    #     # The rest of the Providers
    #     service_providers = ServiceProvider.where(location_id: provider_break_params[:local]).where.not(id: originalBreak.service_provider_id)
    #     service_providers.each do |provider|
    #       break_params[:service_provider_id] = provider.id
    #       breaks = ProviderBreak.new(:start => originalBreak.start, :end => originalBreak.end, :name => originalBreak.end, :break_group_id => originalBreak.break_group_id, :service_provider_id => provider.id)
    #       if breaks.save
    #         breaks.warnings ? warnings = breaks.warnings.full_messages : warnings = []
    #         @break_json.push({id: breaks.id, start: breaks.start, end: breaks.end, service_provider_id: breaks.service_provider_id, name: breaks.name, warnings: warnings})
    #         status = status && true
    #       else
    #         @break_errors.push(breaks.errors.full_messages)
    #         status = status && false
    #       end
    #     end
    #   end
    #   respond_to do |format|
    #     if status
    #       format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
    #       format.json { render :json => @break_json }
    #       format.js { }
    #     else
    #       format.html { render action: 'index' }
    #       format.json { render :json => { :errors => @break_errors }, :status => 422 }
    #       format.js { }
    #     end
    #   end
    # end
  end

  #Edit all repetitions
  def update_repeat_break
    provider_breaks = ProviderBreak.where(break_repeat_id: provider_break_params[:repeat_id]).where(service_provider_id: provider_break_params[:service_provider_id].to_i)
    puts "Repeat ID: " + provider_break_params[:repeat_id]
    break_group = provider_breaks.first.break_group_id
    service_providers = ServiceProvider.where(location_id: provider_break_params[:local])
    @break_json = Array.new
    @break_errors = Array.new
    status = true

    #Differences in hours
    start_diff = (provider_breaks.first.start.to_datetime - provider_break_params[:start].to_datetime)*24
    end_diff = (provider_breaks.first.end.to_datetime - provider_break_params[:end].to_datetime)*24

    puts "Diffs"
    puts start_diff
    puts end_diff

    #if provider_break_params[:service_provider_id].to_i != 0
      provider_breaks.each do |breaks|
     
        #breaks.service_provider_id = provider_break_params[:service_provider_id]
        breaks.name = provider_break_params[:name]
        breaks.start = breaks.start - start_diff.hours
        breaks.end = breaks.end - end_diff.hours
        #breaks.break_group_id = nil

        if breaks.save
          breaks.warnings ? warnings = breaks.warnings.full_messages : warnings = []
          @break_json.push({id: breaks.id, start: breaks.start, end: breaks.end, service_provider_id: breaks.service_provider_id, name: breaks.name, warnings: warnings})
          status = status && true
        else
          @break_errors.push(breaks.errors.full_messages)
          status = status && false
        end
      end
    # else

    #   provider_breaks.each do |breaks|     
    #     #breaks.service_provider_id = provider_break_params[:service_provider_id]
    #     breaks.name = provider_break_params[:name]
    #     breaks.start = breaks.start - start_diff.hours
    #     breaks.end = breaks.end - end_diff.hours

    #     if breaks.save
    #       breaks.warnings ? warnings = breaks.warnings.full_messages : warnings = []
    #       @break_json.push({id: breaks.id, start: breaks.start, end: breaks.end, service_provider_id: breaks.service_provider_id, name: breaks.name, warnings: warnings})
    #       status = status && true
    #     else
    #       @break_errors.push(breaks.errors.full_messages)
    #       status = status && false
    #     end
    #   end      

    # end

    respond_to do |format|
      if status
        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => @break_json }
        format.js { }
      else
        format.html { render action: 'index' }
        format.json { render :json => { :errors => @break_errors }, :status => 422 }
        format.js { }
      end
    end

  end


  def destroy_provider_break
    if provider_break_params[:service_provider_id].to_i != 0
      @provider_break = ProviderBreak.find(params[:id])
      @provider_break.destroy
      respond_to do |format|
        format.html { redirect_to bookings_url }
        format.json { render :json => @provider_break }
      end
    else
      break_group = ProviderBreak.find(params[:id]).break_group_id
      service_providers = ServiceProvider.where(location_id: provider_break_params[:local])
      provider_breaks = ProviderBreak.where(service_provider_id: service_providers).where(break_group_id: break_group)
      @break_json = Array.new
      provider_breaks.each do |provider_break|
        provider_break.destroy
        @break_json.push(provider_break)
      end
      respond_to do |format|
        format.html { redirect_to bookings_url }
        format.json { render :json => @break_json }
      end
    end
  end


  #Destroy all repetitions
  def destroy_repeat_break
    provider_breaks = ProviderBreak.where(:break_repeat_id => params[:provider_break][:repeat_id], :service_provider_id => params[:provider_break][:service_provider_id])
    @break_json =Array.new
    provider_breaks.each do |provider_break|
      provider_break.destroy
      @break_json.push(provider_break)
    end
    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { render :json => @break_json }
    end
  end

  def provider_break_params
    params.require(:provider_break).permit(:start, :end, :service_provider_id, :name, :local, :repeat, :repeat_option, :times, :repeat_end, :repeat_id)
  end
end
