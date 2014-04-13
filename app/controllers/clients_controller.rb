class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  load_and_authorize_resource
  layout "admin"

  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.accessible_by(current_ability)
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
    @client_comment = ClientComment.new
  end

  # GET /clients/1/edit
  def edit
    @activeBookings = Booking.where(:email => @client.email, :service_provider_id => ServiceProvider.where(:company_id => @client.company_id), :status_id => Status.find_by(:name => ['Reservado', 'Pagado'])).where("start > ?", DateTime.now).order(:start) 
    @lastBookings = Booking.where(:email => @client.email, :service_provider_id => ServiceProvider.where(:company_id => @client.company_id)).order(updated_at: :desc).limit(10)
    @next_bookings = Booking
    @client_comment = ClientComment.new
    @client_comments = ClientComment.where(client_id: @client.id)
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(client_params)
    @client.company = Company.find(current_user.company_id)

    respond_to do |format|
      if @client.save
        format.html { redirect_to edit_client_path(@client), notice: 'El cliente fue creado exitosamente.' }
        format.json { render action: 'edit', status: :created, location: @client }
      else
        format.html { render action: 'new' }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update
    @client_comment = ClientComment.new(client_comment_params)
    respond_to do |format|
      if @client.update(client_params)
        if !client_comment_params[:comment].empty?
          @client_comment.save
        end
        format.html { redirect_to edit_client_path(@client), notice: 'El cliente fue actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:company_id, :email, :first_name, :last_name, :phone, :address, :district, :city, :age, :gender, :birth_date)
    end

    def client_comment_params
      params.require(:client_comment).permit(:client_id, :comment)
    end
end
