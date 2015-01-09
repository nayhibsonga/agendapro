  
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
      @provider_break = ProviderBreak.new(provider_break_params.except(:local))
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
      service_providers = ServiceProvider.where(location_id: provider_break_params[:local])
      break_group = ProviderBreak.where(service_provider_id: service_providers).where.not(break_group_id: nil).order(:break_group_id).last
      if break_group.nil?
        break_group = 0
      else
        break_group = break_group.break_group_id + 1
      end
      @break_json = Array.new
      @break_erros = Array.new
      status = true
      service_providers.each do |provider|
        break_params = provider_break_params.except(:local)
        break_params[:service_provider_id] = provider.id
        break_params[:break_group_id] = break_group
        provider_break = ProviderBreak.new(break_params)
        if provider_break.save
          provider_break.warnings ? warnings = provider_break.warnings.full_messages : warnings = []
          @break_json.push({id: provider_break.id, start: provider_break.start, end: provider_break.end, service_provider_id: provider_break.service_provider_id, name: provider_break.name, warnings: warnings})
          status = status && true
        else
          @break_erros.push(provider_break.errors.full_messages)
          status = status && false
        end
      end
      respond_to do |format|
        if status
          format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
          format.json { render :json => @break_json }
          format.js { }
        else
          format.html { render action: 'index' }
          format.json { render :json => { :errors => @break_erros }, :status => 422 }
          format.js { }
        end
      end
    end
  end

  def update_provider_break
    if provider_break_params[:service_provider_id].to_i != 0
      @provider_break = ProviderBreak.find(params[:id])
      respond_to do |format|
        break_params = provider_break_params.except(:local)
        break_params[:break_group_id] = nil
        if @provider_break.update(break_params)

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
      break_group = ProviderBreak.find(params[:id]).break_group_id
      service_providers = ServiceProvider.where(location_id: provider_break_params[:local])
      provider_breaks = ProviderBreak.where(service_provider_id: service_providers).where(break_group_id: break_group)
      @break_json = Array.new
      @break_erros = Array.new
      status = true
      provider_breaks.each do |breaks|
        break_params = provider_break_params.except(:local)
        break_params[:service_provider_id] = breaks.service_provider_id
        break_params[:break_group_id] = break_group
        if breaks.update(break_params)
          breaks.warnings ? warnings = breaks.warnings.full_messages : warnings = []
          @break_json.push({id: breaks.id, start: breaks.start, end: breaks.end, service_provider_id: breaks.service_provider_id, name: breaks.name, warnings: warnings})
          status = status && true
        else
          @break_erros.push(breaks.errors.full_messages)
          status = status && false
        end
      end
      respond_to do |format|
        if status
          format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
          format.json { render :json => @break_json }
          format.js { }
        else
          format.html { render action: 'index' }
          format.json { render :json => { :errors => @break_erros }, :status => 422 }
          format.js { }
        end
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
  
  def provider_break_params
    params.require(:provider_break).permit(:start, :end, :service_provider_id, :name, :local)
  end
end