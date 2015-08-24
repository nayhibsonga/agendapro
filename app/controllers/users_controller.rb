class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]
  #before_action :set_user, only: [:agenda]
  before_action :authenticate_user!, except: [:check_user_email]
  before_action :verify_is_super_admin, except: [:new, :agenda, :add_company, :check_user_email, :get_session_bookings, :get_session_summary]
  layout "admin", except: [:agenda, :add_company, :get_session_bookings, :get_session_summary]
  load_and_authorize_resource

  # GET /users
  # GET /users.json
  def index
    @users = User.where(company_id: current_user.company_id)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
    @user.company_id = current_user.company_id
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.company_id = current_user.company_id

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Usuario creado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Usuario actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def agenda
    @lat = cookies[:lat]
    @lng = cookies[:lng]
    if cookies[:formatted_address]
      @formatted_address = cookies[:formatted_address].unpack("C*").pack("U*")
    end

    #@activeBookings = Booking.where(:user_id => params[:id], :status_id => Status.find_by(:name => ['Reservado', 'Pagado', 'Confirmado'])).where("start > ?", DateTime.now).order(:start) 
    #@lastBookings = Booking.where(:user_id => params[:id]).order(updated_at: :desc).limit(10)
    @user = current_user
    @client_ids = Client.where(:email => current_user.email).pluck(:id)
    @preSessionBookings = SessionBooking.where(:client_id => @client_ids)

    @preSessionBookings.each do |sb|
      if sb.user_id.nil?
        sb.user_id = current_user.id
        sb.save
      end
      if sb.bookings.count == 0
        sb.delete
      end
    end

    @preSessionBookings = SessionBooking.where(:client_id => @client_ids)

    @sessionBookings = []

    @preSessionBookings.each do |session_booking|

      include_sb = false

      if session_booking.sessions_taken < session_booking.sessions_amount
        include_sb = true
      else
        session_booking.bookings.each do |booking|
          if booking.start > DateTime.now
            include_sb = true
          end
        end
      end

      if include_sb
        @sessionBookings << session_booking
      end

    end

    @activeBookings = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(:client_id => @client_ids, :status_id => Status.find_by(:name => ['Reservado', 'Pagado', 'Confirmado'])).where("start > ?", DateTime.now).order(:start) 
    @lastBookings = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(:client_id => @client_ids).order(updated_at: :desc).limit(10)
    render :layout => 'results'
  end

  def get_session_bookings

    @sessionBooking = SessionBooking.find(params[:session_booking_id])
    respond_to do |format|
      format.html { render :partial => 'get_session_bookings' }
      format.json { render json: @sessionBooking }
    end

  end

  def get_session_summary

    @sessionBooking = SessionBooking.find(params[:session_booking_id])
    respond_to do |format|
      format.html { render :partial => 'get_session_summary' }
      format.json { render json: @sessionBooking }
    end

  end

  def check_user_email
    @user = User.find_by(:email => params[:user][:email])
    render :json => @user.nil?
  end

  def delete_session_booking
    @result = ""
    session_booking = SessionBooking.find(params[:session_booking_id])
    if !session_booking.service_promo_id.nil? || session_booking.bookings.first.payed
      #Forn now, can't delete when payed
      @result << "payed"
    end
    if session_booking.delete
      @result << "ok"
    else
      @result << "error"
    end

    render :json => @result
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:id, :first_name, :last_name, :email, :phone, :password, :role_id, :company_id, :uid, :provider, :receives_offers)
    end
end
