class ProviderBreaksController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "admin"

  def provider_breaks
    start_date = DateTime.parse(params[:start])
    end_date = DateTime.parse(params[:end])
    provider_breaks = ProviderBreak.where(service_provider_id: params[:service_provider_id]).where('(provider_breaks.start,provider_breaks.end) overlaps (date ?,date ?)', end_date, start_date).order(:start)
    render :json => provider_breaks
  end

  def get_provider_break

    provider_break = ProviderBreak.find(params[:id])
    provider_break_repeat = {}
    service_providers = {}
    group_service_providers = {}

    if provider_break.break_repeat_id != nil

      #Return provider_break info, provider_break_repeat info, and service_providers ids.

      provider_break_repeat = ProviderBreakRepeat.find(provider_break.break_repeat_id)
      service_providers = ServiceProvider.where(:id => ProviderBreak.where(:break_repeat_id => provider_break_repeat.id).pluck(:service_provider_id))

    end

    if provider_break.break_group_id

      group_service_providers = ServiceProvider.where(:id => ProviderBreak.where(:break_group_id => provider_break.break_group_id).pluck(:service_provider_id))

    end

    provider_break_json = {:provider_break => provider_break, :provider_break_repeat => provider_break_repeat, :service_providers => service_providers, :group_service_providers => group_service_providers}

    if mobile_request?
      @company = current_user.company
    end
    respond_to do |format|
      format.html { }
      format.json { render :json => provider_break_json }
    end

  end

  def create_provider_break

    ids = params[:provider_break][:service_provider_id]

    if(ids.nil? || ids.length < 1)
      @break_json = Array.new
      respond_to do |format|
        format.html { redirect_to bookings_path, notice: 'No se seleccionaron proveedores.' }
        format.json { render :json => @break_json }
        format.js { }
      end
      return
    elsif ids.count == 1

      @break_json = Array.new

      if params[:provider_break][:repeat] == "never"

        @provider_break = ProviderBreak.new(:start => params[:provider_break][:start], :end => params[:provider_break][:end], :service_provider_id => ids[0].to_i, :name => params[:provider_break][:name])

        respond_to do |format|
          if @provider_break.save
            @provider_break.warnings ? warnings = @provider_break.warnings.full_messages : warnings = []
            @break_json << {id: @provider_break.id, start: @provider_break.start, end: @provider_break.end, service_provider_id: @provider_break.service_provider_id, name: @provider_break.name, warnings: warnings}
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
        
        @break_errors = Array.new

        @provider_break_repeat = ProviderBreakRepeat.create(:start_date => params[:provider_break][:start].to_datetime, :repeat_option => params[:provider_break][:repeat_option], :repeat_type => params[:provider_break][:repeat])

        status = true

        repeat_id = @provider_break_repeat.id

        #repeat_id = 0
        #repeat_group = ProviderBreak.where.not(break_repeat_id: nil).order(:break_repeat_id).last
        #if repeat_group.nil?
        #  repeat_id = 0
        #else
        #  repeat_id = repeat_group.break_repeat_id + 1
        #end

        #repeat_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
        first_start_date = params[:provider_break][:start].to_datetime
        first_end_date = params[:provider_break][:end].to_datetime
        start_date = first_start_date
        end_date = first_end_date
        if params[:provider_break][:repeat_option] == "times"
          times = 1
          if params[:provider_break][:times] != ""
            times = params[:provider_break][:times].to_i
          end
          @provider_break_repeat.times = times
          for i in 0..times-1
            if params[:provider_break][:repeat] == "daily"
              start_date = first_start_date + i.days
              end_date = first_end_date + i.days
            elsif params[:provider_break][:repeat] == "weekly"
              start_date = first_start_date + i.weeks
              end_date = first_end_date + i.weeks
            elsif params[:provider_break][:repeat] == "biweekly"
              start_date = first_start_date + (i*2).weeks
              end_date = first_end_date + (i*2).weeks
            elsif params[:provider_break][:repeat] == "triweekly"
              start_date = first_start_date + (i*3).weeks
              end_date = first_end_date + (i*3).weeks
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
            provider_break = ProviderBreak.new(:start => start_date, :end => end_date, :service_provider_id => ids[0].to_i, :name => params[:provider_break][:name], :break_repeat_id => repeat_id)

            if provider_break.save
              provider_break.warnings ? warnings = provider_break.warnings.full_messages : warnings = []
              @break_json.push({id: provider_break.id, start: provider_break.start, end: provider_break.end, service_provider_id: provider_break.service_provider_id, name: provider_break.name, warnings: warnings})
              status = status && true
            else
              @break_errors.push(provider_break.errors.full_messages)
              status = status && false
            end

          end
          @provider_break_repeat.end_date = end_date
        else


          start_date = first_start_date
          end_date = first_end_date
          final_date = params[:provider_break][:repeat_end].to_datetime
          @provider_break_repeat.end_date = final_date
          @provider_break_repeat.times = nil

          i = 0

          while start_date < final_date

            if params[:provider_break][:repeat] == "daily"
              start_date = first_start_date + i.days
              end_date = first_end_date + i.days
            elsif params[:provider_break][:repeat] == "weekly"
              start_date = first_start_date + i.weeks
              end_date = first_end_date + i.weeks
            elsif params[:provider_break][:repeat] == "biweekly"
              start_date = first_start_date + (i*2).weeks
              end_date = first_end_date + (i*2).weeks
            elsif params[:provider_break][:repeat] == "triweekly"
              start_date = first_start_date + (i*3).weeks
              end_date = first_end_date + (i*3).weeks
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

            provider_break = ProviderBreak.new(:start => start_date, :end => end_date, :service_provider_id => ids[0].to_i, :name => params[:provider_break][:name], :break_repeat_id => repeat_id)

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

        @provider_break_repeat.save

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

      service_providers = ServiceProvider.find(ids)
      break_group = ProviderBreak.where.not(break_group_id: nil).order('break_group_id asc').last
      if break_group.nil?
        break_group = 0
      else
        break_group = break_group.break_group_id + 1
      end


      @break_json = Array.new
      @break_errors = Array.new
      status = true


      if params[:provider_break][:repeat] != "never"

        @provider_break_repeat = ProviderBreakRepeat.create(:start_date => params[:provider_break][:start].to_datetime, :repeat_option => params[:provider_break][:repeat_option], :repeat_type => params[:provider_break][:repeat])

        repeat_id = @provider_break_repeat.id

        service_providers.each do |provider|
          
          break_group_id = break_group
          
          
          first_start_date = params[:provider_break][:start].to_datetime
          first_end_date = params[:provider_break][:end].to_datetime
          start_date = first_start_date
          end_date = first_end_date

          if params[:provider_break][:repeat_option] == "times"
            times = 1
            if params[:provider_break][:times] != ""
              times = params[:provider_break][:times].to_i
            end
          @provider_break_repeat.times = times
            for i in 0..times-1
              if params[:provider_break][:repeat] == "daily"
                start_date = first_start_date + i.days
                end_date = first_end_date + i.days
              elsif params[:provider_break][:repeat] == "weekly"
                start_date = first_start_date + i.weeks
                end_date = first_end_date + i.weeks
              elsif params[:provider_break][:repeat] == "biweekly"
                start_date = first_start_date + (i*2).weeks
                end_date = first_end_date + (i*2).weeks
              elsif params[:provider_break][:repeat] == "triweekly"
                start_date = first_start_date + (i*3).weeks
                end_date = first_end_date + (i*3).weeks
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
            @provider_break_repeat.end_date = end_date
          else

            start_date = first_start_date
            end_date = first_end_date
            final_date = params[:provider_break][:repeat_end].to_datetime
            @provider_break_repeat.end_date = final_date
            @provider_break_repeat.times = nil

            i = 0

            while start_date < final_date

              if params[:provider_break][:repeat] == "daily"
                start_date = first_start_date + i.days
                end_date = first_end_date + i.days
              elsif params[:provider_break][:repeat] == "weekly"
                start_date = first_start_date + i.weeks
                end_date = first_end_date + i.weeks
              elsif params[:provider_break][:repeat] == "biweekly"
                start_date = first_start_date + (i*2).weeks
                end_date = first_end_date + (i*2).weeks
              elsif params[:provider_break][:repeat] == "triweekly"
                start_date = first_start_date + (i*3).weeks
                end_date = first_end_date + (i*3).weeks
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
        @provider_break_repeat.save
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
      ids = params[:provider_break][:service_provider_id]
      @break_errors = Array.new
      @break_json = Array.new

      status = true
      new_name = @provider_break.name
      if provider_break_params[:name] && provider_break_params[:name] != ""
        new_name = provider_break_params[:name]
      end

      if(ids.nil? || ids.length < 1)
        @break_json = Array.new
        respond_to do |format|
          format.html { redirect_to bookings_path, notice: 'No se seleccionaron proveedores.' }
          format.json { render :json => @break_json }
          format.js { }
        end
        return
      end
      
      service_providers = ServiceProvider.find(ids)
      group_service_providers = []

      if @provider_break.break_group_id != nil
        group_service_providers = ServiceProvider.where(:id => ProviderBreak.where(:break_group_id => @provider_break.break_group_id).pluck(:service_provider_id))

        if (service_providers - group_service_providers).empty? and (group_service_providers - service_providers).empty?

          #The providers given are the same of the group
          provider_breaks = ProviderBreak.where(:break_group_id => @provider_break.break_group_id)

          provider_breaks.each do |provider_break|

            provider_break.name = new_name
            provider_break.start = provider_break_params[:start]
            provider_break.end = provider_break_params[:end]
            provider_break.break_repeat_id = nil

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

          new_providers = service_providers - group_service_providers
          old_providers = group_service_providers - service_providers

          #Add new given providers to the group.
          new_providers.each do |service_provider|

            provider_break = ProviderBreak.new

            provider_break.service_provider_id = service_provider.id
            provider_break.name = new_name
            provider_break.start = provider_break_params[:start]
            provider_break.end = provider_break_params[:end]
            provider_break.break_group_id = @provider_break.break_group_id
            provider_break.break_repeat_id = nil

            if provider_break.save
              provider_break.warnings ? warnings = provider_break.warnings.full_messages : warnings = []
              @break_json.push({id: provider_break.id, start: provider_break.start, end: provider_break.end, service_provider_id: provider_break.service_provider_id, name: provider_break.name, warnings: warnings})
              status = status && true
            else
              @break_errors.push(provider_break.errors.full_messages)
              status = status && false
            end

          end

          #Detach providers that weren't given in params from the group. Give them a new break_group_id.
          if !old_providers.empty?

            break_group = ProviderBreak.where('break_group_id is not null').order('break_group_id asc').last
            new_break_group_id = 0
            if break_group.nil?
              new_break_group_id = 0
            else
              new_break_group = break_group.break_group_id + 1
            end

            old_provider_breaks = ProviderBreak.where(:service_provider_id => old_providers.map(&:id), :break_group_id => @provider_break.break_group_id)

            old_provider_breaks.each do |provider_break|
              provider_break.break_group_id = new_break_group_id
              
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

          #For those given that are not new, just update their values.
          update_providers = service_providers - new_providers - old_providers
          update_provider_breaks = ProviderBreak.where(:service_provider_id => update_providers.map(&:id), :break_group_id => @provider_break.break_group_id)
          update_provider_breaks.each do |provider_break|

            provider_break.name = new_name
            provider_break.start = provider_break_params[:start]
            provider_break.end = provider_break_params[:end]
            
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

      else

        #It has no group. If it's one, just edit it. Else, edit it and create the rest with group.
        if ids.length == 1

          @provider_break.service_provider_id = ids[0]
          @provider_break.name = new_name
          @provider_break.start = provider_break_params[:start]
          @provider_break.end = provider_break_params[:end]
          @provider_break.break_repeat_id = nil

          if @provider_break.save
            @provider_break.warnings ? warnings = @provider_break.warnings.full_messages : warnings = []
            @break_json.push({id: @provider_break.id, start: @provider_break.start, end: @provider_break.end, service_provider_id: @provider_break.service_provider_id, name: @provider_break.name, warnings: warnings})
            status = status && true
          else
            @break_errors.push(provider_break.errors.full_messages)
            status = status && false
          end

        else

          
          new_providers = []
          service_providers.each do |service_provider|
            if service_provider.id != @provider_break.service_provider.id
              new_providers << service_provider
            end
          end

          break_group = ProviderBreak.where('break_group_id is not null').order('break_group_id asc').last
          new_break_group_id = 0
          if break_group.nil?
            new_break_group_id = 0
          else
            new_break_group = break_group.break_group_id + 1
          end

          @provider_break.name = new_name
          @provider_break.start = provider_break_params[:start]
          @provider_break.end = provider_break_params[:end]
          @provider_break.break_group_id = new_break_group_id
          @provider_break.break_repeat_id = nil

          if @provider_break.save
            @provider_break.warnings ? warnings = @provider_break.warnings.full_messages : warnings = []
            @break_json.push({id: @provider_break.id, start: @provider_break.start, end: @provider_break.end, service_provider_id: @provider_break.service_provider_id, name: @provider_break.name, warnings: warnings})
            status = status && true
          else
            @break_errors.push(provider_break.errors.full_messages)
            status = status && false
          end

          #Add new given providers to the group.
          new_providers.each do |service_provider|

            provider_break = ProviderBreak.new

            provider_break.service_provider_id = service_provider.id
            provider_break.name = new_name
            provider_break.start = provider_break_params[:start]
            provider_break.end = provider_break_params[:end]
            provider_break.break_group_id = new_break_group_id
            provider_break.break_repeat_id = nil

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

      end

      respond_to do |format|
        if status
          format.html { redirect_to bookings_path, notice: 'Breaks were successfully created.' }
          format.json { render :json => @break_json }
          format.js { }
        else
          format.html { render action: 'index' }
          format.json { render :json => { :errors => @break_errors }, :status => 422 }
          format.js { }
        end
      end

  end

  #Edit all repetitions
  def update_repeat_break
    
    ids = provider_break_params[:service_provider_id]

    if(ids.nil? || ids.length < 1)
      @break_json = Array.new
      respond_to do |format|
        format.html { redirect_to bookings_path, notice: 'No se seleccionaron proveedores.' }
        format.json { render :json => @break_json }
        format.js { }
      end
      return
    end

    provider_break_repeat = ProviderBreakRepeat.find(provider_break_params[:repeat_id])

    #Get series for given providers. Create new series and detach it from the old one.
    provider_breaks = ProviderBreak.where(break_repeat_id: provider_break_repeat.id, :service_provider_id => ids)
    all_provider_breaks = ProviderBreak.where(break_repeat_id: provider_break_repeat.id)

    @break_json = Array.new
    @break_errors = Array.new
    @break_deletes = Array.new
    @final_json = Array.new
    status = true

    service_providers = ServiceProvider.find(ids)
    all_service_providers = ServiceProvider.where(:id => ProviderBreak.where(:break_repeat_id => provider_break_repeat.id).pluck(:service_provider_id))
    new_service_providers = service_providers - all_service_providers
    old_service_providers = all_service_providers - service_providers
    update_service_providers = service_providers - new_service_providers - old_service_providers

    #If all original ids are given, edit everything
    if (all_service_providers - service_providers).empty? and (service_providers - all_service_providers).empty?


      #Destroy current breaks before creating new ones
      provider_breaks.each do |pb|
        @break_deletes << pb
        pb.delete
      end

      #Edit ProviderBreakRepeat and redo breaks for given providers using its sart_date and the given params.
      provider_break_repeat.repeat_option = params[:provider_break][:repeat_option]
      provider_break_repeat.repeat_type = params[:provider_break][:repeat]

      repeat_id = provider_break_repeat.id

      service_providers.each do |provider|
        
        break_group_id = nil       
        
        #Given start and end could differ from the original, so we have to move them.
        given_start_date = params[:provider_break][:start].to_datetime
        given_end_date = params[:provider_break][:end].to_datetime
        given_diff = (given_end_date - given_start_date)*24

        first_start_date = given_start_date
        first_end_date = given_start_date + given_diff.hours

        start_date = first_start_date
        end_date = first_end_date

        if params[:provider_break][:repeat_option] == "times"
          times = 1
          if params[:provider_break][:times] != ""
            times = params[:provider_break][:times].to_i
          end
          provider_break_repeat.times = times
          for i in 0..times-1
            if params[:provider_break][:repeat] == "daily"
              start_date = first_start_date + i.days
              end_date = first_end_date + i.days
            elsif params[:provider_break][:repeat] == "weekly"
              start_date = first_start_date + i.weeks
              end_date = first_end_date + i.weeks
            elsif params[:provider_break][:repeat] == "biweekly"
              start_date = first_start_date + (i*2).weeks
              end_date = first_end_date + (i*2).weeks
            elsif params[:provider_break][:repeat] == "triweekly"
              start_date = first_start_date + (i*3).weeks
              end_date = first_end_date + (i*3).weeks
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
          provider_break_repeat.end_date = end_date
        else

          start_date = first_start_date
          end_date = first_end_date
          final_date = params[:provider_break][:repeat_end].to_datetime
          provider_break_repeat.end_date = final_date
          provider_break_repeat.times = nil

          i = 0

          while start_date < final_date

            if params[:provider_break][:repeat] == "daily"
              start_date = first_start_date + i.days
              end_date = first_end_date + i.days
            elsif params[:provider_break][:repeat] == "weekly"
              start_date = first_start_date + i.weeks
              end_date = first_end_date + i.weeks
            elsif params[:provider_break][:repeat] == "biweekly"
              start_date = first_start_date + (i*2).weeks
              end_date = first_end_date + (i*2).weeks
            elsif params[:provider_break][:repeat] == "triweekly"
              start_date = first_start_date + (i*3).weeks
              end_date = first_end_date + (i*3).weeks
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
      provider_break_repeat.save

    else 

      #KEEP CURRENT PROVIDER_BREAK_REPEAT FOR NEW AND REST. CREATE A NEW ONE FOR OLD

      #If there are missing ids, detach those breaks from the series by creating a new one.
      if !(old_service_providers).empty?

        new_provider_break_repeat = ProviderBreakRepeat.new(provider_break_repeat.attributes.to_options)
        new_provider_break_repeat.id = nil
        new_provider_break_repeat.save
        old_provider_breaks = ProviderBreak.where(:break_repeat_id => provider_break_repeat.id, :service_provider_id => old_service_providers.map(&:id))

        old_provider_breaks.each do |provider_break|
          provider_break.break_repeat_id = new_provider_break_repeat.id
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

      #If there are new ids, create the breaks and add them to the series
      if !(new_service_providers).empty?

        #Create breaks given providers using its sart_date and the given params.
        provider_break_repeat.repeat_option = params[:provider_break][:repeat_option]
        provider_break_repeat.repeat_type = params[:provider_break][:repeat]

        repeat_id = provider_break_repeat.id

        new_service_providers.each do |provider|
          
          break_group_id = nil       
          
          #Given start and end could differ from the original, so we have to move them.
          given_start_date = params[:provider_break][:start].to_datetime
          given_end_date = params[:provider_break][:end].to_datetime
          given_diff = (given_end_date - given_start_date)*24

          first_start_date = given_start_date
          first_end_date = given_start_date + given_diff.hours

          start_date = first_start_date
          end_date = first_end_date

          if params[:provider_break][:repeat_option] == "times"
            times = 1
            if params[:provider_break][:times] != ""
              times = params[:provider_break][:times].to_i
            end
            provider_break_repeat.times = times
            for i in 0..times-1
              if params[:provider_break][:repeat] == "daily"
                start_date = first_start_date + i.days
                end_date = first_end_date + i.days
              elsif params[:provider_break][:repeat] == "weekly"
                start_date = first_start_date + i.weeks
                end_date = first_end_date + i.weeks
              elsif params[:provider_break][:repeat] == "biweekly"
                start_date = first_start_date + (i*2).weeks
                end_date = first_end_date + (i*2).weeks
              elsif params[:provider_break][:repeat] == "triweekly"
                start_date = first_start_date + (i*3).weeks
                end_date = first_end_date + (i*3).weeks
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
            provider_break_repeat.end_date = end_date
          else

            start_date = first_start_date
            end_date = first_end_date
            final_date = params[:provider_break][:repeat_end].to_datetime
            provider_break_repeat.end_date = final_date
            provider_break_repeat.times = nil

            i = 0

            while start_date < final_date

              if params[:provider_break][:repeat] == "daily"
                start_date = first_start_date + i.days
                end_date = first_end_date + i.days
              elsif params[:provider_break][:repeat] == "weekly"
                start_date = first_start_date + i.weeks
                end_date = first_end_date + i.weeks
              elsif params[:provider_break][:repeat] == "biweekly"
                start_date = first_start_date + (i*2).weeks
                end_date = first_end_date + (i*2).weeks
              elsif params[:provider_break][:repeat] == "triweekly"
                start_date = first_start_date + (i*3).weeks
                end_date = first_end_date + (i*3).weeks
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
        provider_break_repeat.save

      end

      #For the rest, update them and their repeat_id


      #Delete and redo breaks for given providers using its sart_date and the given params.
      provider_break_repeat.repeat_option = params[:provider_break][:repeat_option]
      provider_break_repeat.repeat_type = params[:provider_break][:repeat]

      repeat_id = provider_break_repeat.id

      update_provider_breaks = ProviderBreak.where(:break_repeat_id => repeat_id, :service_provider_id => update_service_providers.map(&:id))

      update_provider_breaks.each do |provider_break|

        @break_deletes << provider_break
        provider_break.delete

      end      

      update_service_providers.each do |provider|
        
        break_group_id = nil       
        
        #Given start and end could differ from the original, so we have to move them.
        given_start_date = params[:provider_break][:start].to_datetime
        given_end_date = params[:provider_break][:end].to_datetime
        given_diff = (given_end_date - given_start_date)*24

        first_start_date = given_start_date
        first_end_date = given_start_date + given_diff.hours

        start_date = first_start_date
        end_date = first_end_date

        if params[:provider_break][:repeat_option] == "times"
          times = 1
          if params[:provider_break][:times] != ""
            times = params[:provider_break][:times].to_i
          end
          provider_break_repeat.times = times
          for i in 0..times-1
            if params[:provider_break][:repeat] == "daily"
              start_date = first_start_date + i.days
              end_date = first_end_date + i.days
            elsif params[:provider_break][:repeat] == "weekly"
              start_date = first_start_date + i.weeks
              end_date = first_end_date + i.weeks
            elsif params[:provider_break][:repeat] == "biweekly"
              start_date = first_start_date + (i*2).weeks
              end_date = first_end_date + (i*2).weeks
            elsif params[:provider_break][:repeat] == "triweekly"
              start_date = first_start_date + (i*3).weeks
              end_date = first_end_date + (i*3).weeks
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
          provider_break_repeat.end_date = end_date
        else

          start_date = first_start_date
          end_date = first_end_date
          final_date = params[:provider_break][:repeat_end].to_datetime
          provider_break_repeat.end_date = final_date
          provider_break_repeat.times = nil

          i = 0

          while start_date < final_date

            if params[:provider_break][:repeat] == "daily"
              start_date = first_start_date + i.days
              end_date = first_end_date + i.days
            elsif params[:provider_break][:repeat] == "weekly"
              start_date = first_start_date + i.weeks
              end_date = first_end_date + i.weeks
            elsif params[:provider_break][:repeat] == "biweekly"
              start_date = first_start_date + (i*2).weeks
              end_date = first_end_date + (i*2).weeks
            elsif params[:provider_break][:repeat] == "triweekly"
              start_date = first_start_date + (i*3).weeks
              end_date = first_end_date + (i*3).weeks
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
      provider_break_repeat.save


    end

    ############
    # OLD CODE #
    ############

    # if provider_break_repeat.repeat_option == params[:provider_break][:repeat_option] and provider_break_repeat.repeat_type == params[:provider_break][:repeat]

    #   first_break = ProviderBreak.find(params[:provider_break][:id])

    #   #Differences in hours
    #   start_diff = (first_break.start.to_datetime - provider_break_params[:start].to_datetime)*24
    #   end_diff = (first_break.end.to_datetime - provider_break_params[:end].to_datetime)*24

    #   provider_breaks.each do |breaks|
     
    #     breaks.service_provider_id = provider_break_params[:service_provider_id]
    #     breaks.name = provider_break_params[:name]
    #     breaks.start = breaks.start - start_diff.hours
    #     breaks.end = breaks.end - end_diff.hours
    #     #breaks.break_group_id = nil

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


    ############
    # OLD CODE #
    ############
    @final_json << @break_json
    @final_json << @break_deletes

    respond_to do |format|
      if status
        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => @final_json }
        format.js { }
      else
        format.html { render action: 'index' }
        format.json { render :json => { :errors => @break_errors }, :status => 422 }
        format.js { }
      end
    end

  end


  def destroy_provider_break

    provider_break = ProviderBreak.find(params[:id])
    @break_json = Array.new

    if !provider_break.break_group_id.nil?

      ids = provider_break_params[:service_provider_id]
      provider_breaks = ProviderBreak.where(:service_provider_id => ids, :break_group_id => provider_break.break_group_id)

      provider_breaks.each do |provider_break|
        provider_break.destroy
        @break_json.push(provider_break)
      end

    else

      provider_break.destroy
      @break_json.push(provider_break)

    end

    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { render :json => @break_json }
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

  # GET /provider_breaks/new
  def new
    @break = ProviderBreak.new
    if mobile_request?
      @company = current_user.company
      @date = DateTime.now
      if !params[:date].blank?
        @date = params[:date].to_time
      end
    end
  end

  def provider_break_params
    params.require(:provider_break).permit(:id, :start, :end, :name, :local, :repeat, :repeat_option, :times, :repeat_end, :repeat_id, :service_provider_id => [])
  end
end