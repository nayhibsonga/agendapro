class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  load_and_authorize_resource
  layout "admin"

  # GET /clients
  # GET /clients.json
  def index
    @locations = Location.where(company_id: current_user.company_id, active: true)
    @service_providers = ServiceProvider.where(company_id: current_user.company_id, active: true)
    @clients = Client.accessible_by(current_ability).search(params[:search]).filter_location(params[:location]).filter_provider(params[:provider]).filter_gender(params[:gender]).paginate(:page => params[:page], :per_page => 25)

    @max_mails = current_user.company.company_setting.daily_mails
    @mails_left = current_user.company.company_setting.daily_mails - current_user.company.company_setting.sent_mails
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @activeBookings = Array.new
    @lastBookings = Array.new
    @client = Client.new
    @client_comment = ClientComment.new
  end

  # GET /clients/1/edit
  def edit
    @activeBookings = Booking.where(:email => @client.email, :service_provider_id => ServiceProvider.where(:company_id => @client.company_id), :status_id => Status.find_by(:name => ['Reservado', 'Pagado'])).where("start > ?", DateTime.now).order(:start).limit(5)
    @lastBookings = Booking.where(:email => @client.email, :service_provider_id => ServiceProvider.where(:company_id => @client.company_id)).order(updated_at: :desc).limit(5)
    @next_bookings = Booking
    @client_comment = ClientComment.new
    @client_comments = ClientComment.where(client_id: @client.id).order(created_at: :desc)
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(client_params)
    @client.company = Company.find(current_user.company_id)

    respond_to do |format|
      if @client.save
        format.html { redirect_to clients_path, notice: 'El cliente fue creado exitosamente.' }
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
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to clients_path, notice: 'El cliente fue actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_comment
    @client_comment = ClientComment.new(client_comment_params)
    respond_to do |format|
      if @client_comment.save
        format.html { redirect_to edit_client_path(@client), notice: 'El cliente fue creado exitosamente.' }
        format.json { render :json => @client_comment }
      else
        format.html { render action: 'new' }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy_comment
    @client_comment = ClientComment.find(client_comment_params[:id])
    @client_comment.destroy
    respond_to do |format|
      format.html { render :json => @client_comment }
      format.json { head :no_content }
    end
  end

  def update_comment
    @client_comment = ClientComment.find(client_comment_params[:id])
    @client = @client_comment.client
    @client_comment.update(client_comment_params)
    respond_to do |format|
      format.html { render :json => @client_comment }
      format.json { head :no_content }
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.client_comments.destroy_all
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url }
      format.json { head :no_content }
    end
  end

  def send_mail
    # Sumar mails eviados
    current_sent = current_user.company.company_setting.sent_mails
    sent_now = params[:to].split(',').length
    current_user.company.company_setting.update_attributes :sent_mails => (current_sent + sent_now)

    clients = Array.new
    params[:to].split(',').each do |client_mail|
      client_info = {
        :email => client_mail,
        :type => 'bcc'
      }
      clients.push(client_info)
    end

    if current_user.company.logo_url
      company_img = {
        :type => 'image/' +  File.extname(current_user.company.logo_url),
        :name => 'company_img.jpg',
        :content => Base64.encode64(File.read('public' + current_user.company.logo_url.to_s))
      }
    else
      company_img = {}
    end

    if params[:attachment]
      attachment = {
        :type => params[:attachment].content_type,
        :name => params[:attachment].original_filename,
        :content => Base64.encode64(File.read(params[:attachment].tempfile))
      }
    else
      attachment = {}
    end

    ClientMailer.send_client_mail(current_user, clients, params[:subject], params[:message], company_img, attachment)

    redirect_to '/clients', notice: 'E-mail enviado correctamente.'
  end

  def suggestion
    @company = Company.where(id: current_user.company_id)
    @clients = Client.where(company_id: @company).pluck(:first_name, :last_name, :email, :phone).uniq

    @clients_arr = Array.new
    @clients.each do |client|
      label = client[2] + ' - ' + client[1] + ', ' + client[0]
      @clients_arr.push({:label => label, :value => client})
    end

    render :json => @clients_arr
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
      params.require(:client_comment).permit(:id, :client_id, :comment)
    end
end
