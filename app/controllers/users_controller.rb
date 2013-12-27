class UsersController < ApplicationController
  #before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :new, :bookService]
  before_action :verify_is_super_admin, except: [:new, :bookService]
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Usuario fue creado exitosamente.' }
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
        format.html { redirect_to @user, notice: 'Usuario fue actualizado exitosamente.' }
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

  def bookService
    @user = User.create(first_name: params[:firstName], last_name: params[:lastName], email: params[:email], phone: params[:phone], role: Role.find_by_name('Usuario No Registrado'))
    if @user.save
      @booking = Booking.create(start: params[:start], end: params[:end], notes: params[:comment], service_provider_id: params[:provider], user_id: @user.id, service_id: params[:service], location_id: params[:location], status_id: Status.find_by_name(Reservado))
      if @booking.sava
        redirect_to root_path #mostrar pagina succes
      else
        flash[:alert] = "Error guardando datos de agenda"
        redirect_to root_path
      end
    else
      flash[:alert] = "Error guardando datos de Usuario"
      redirect_to root_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :user_name, :password, :role_id)
    end
end
