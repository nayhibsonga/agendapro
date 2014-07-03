  
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
    @provider_break = ProviderBreak.new(provider_break_params)
    respond_to do |format|
      if @provider_break.save
        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => @provider_break }
        format.js { }
      else
        format.html { render action: 'index' }
        format.json { render :json => { :errors => @provider_break.errors.full_messages }, :status => 422 }
        format.js { }
      end
    end
  end

  def update_provider_break
    @provider_break = ProviderBreak.find(params[:id])
    respond_to do |format|
      if @provider_break.update(provider_break_params)
        format.html { redirect_to bookings_path, notice: 'Booking was successfully created.' }
        format.json { render :json => @provider_break }
        format.js { }
      else
        format.html { render action: 'index' }
        format.json { render :json => { :errors => @provider_break.errors.full_messages }, :status => 422 }
        format.js { }
      end
    end
  end

  def destroy_provider_break
    @provider_break = ProviderBreak.find(params[:id])
    @provider_break.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { render :json => @provider_break }
    end
  end
  
  def provider_break_params
    params.require(:provider_break).permit(:start, :end, :service_provider_id, :name)
  end
end