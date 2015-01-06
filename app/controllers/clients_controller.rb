class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:client_loader]
  before_action :quick_add
  load_and_authorize_resource
  layout "admin"

  # GET /clients
  # GET /clients.json
  def index
    @locations = Location.where(company_id: current_user.company_id, active: true)
    @service_providers = ServiceProvider.where(company_id: current_user.company_id, active: true)
    @services = Service.where(company_id: current_user.company_id, active: true)
    @clients = Client.accessible_by(current_ability).search(params[:search]).filter_location(params[:location]).filter_provider(params[:provider]).filter_service(params[:service]).filter_gender(params[:gender]).filter_birthdate(params[:option]).order(:last_name, :first_name).paginate(:page => params[:page], :per_page => 25)

    @max_mails = current_user.company.company_setting.daily_mails
    @mails_left = current_user.company.company_setting.daily_mails - current_user.company.company_setting.sent_mails

    @from_collection = current_user.company.company_from_email.where(confirmed: true)

    @clients_export = Client.accessible_by(current_ability).search(params[:search]).filter_location(params[:location]).filter_provider(params[:provider]).filter_service(params[:service]).filter_gender(params[:gender]).order(:last_name, :first_name)
    respond_to do |format|
      format.html
      format.csv
      format.xls
    end
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
    @activeBookings = Booking.where(:client_id => @client).where("start > ?", DateTime.now).order(start: :asc)
    @lastBookings = Booking.where(:client_id => @client).where("start <= ?", DateTime.now).order(start: :desc)
    @next_bookings = Booking
    @client_comment = ClientComment.new
    @client_comments = ClientComment.where(client_id: @client).order(created_at: :desc)
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(client_params)
    @client.company = Company.find(current_user.company_id)

    respond_to do |format|
      if @client.save
        format.html { redirect_to clients_path, notice: 'Cliente creado exitosamente.' }
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
        format.html { redirect_to clients_path, notice: 'Cliente actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def history
    @client = Client.find(params[:id])
    @bookings = @client.bookings
  end

  def bookings_history
    client = Client.find(params[:id])
    bookings = []
    client.bookings.where('start < ?', Time.now).order(start: :desc).limit(10).each do |booking|
      bookings.push( { start: booking.start, service: booking.service.name, provider: booking.service_provider.public_name, status: booking.status.name, notes: booking.notes, comment: booking.company_comment } )
    end

    render :json => bookings
  end

  def create_comment
    @client_comment = ClientComment.new(client_comment_params)
    respond_to do |format|
      if @client_comment.save
        format.html { redirect_to edit_client_path(@client), notice: 'Cliente creado exitosamente.' }
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

  def compose_mail
    @from_collection = current_user.company.company_from_email.where(confirmed: true)
    @to = '';
    params[:to].each do |mail|
      @to += mail + ', '
    end
    @to = @to.chomp(', ')
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

    if params[:attachment]
      attachment = {
        :type => params[:attachment].content_type,
        :name => params[:attachment].original_filename,
        :content => Base64.encode64(File.read(params[:attachment].tempfile))
      }
    else
      attachment = {}
    end

    ClientMailer.send_client_mail(current_user, clients, params[:subject], params[:message], attachment, params[:from])

    redirect_to '/clients', notice: 'E-mail enviado exitosamente.'
  end

  def suggestion
    @clients = Client.where(company_id: current_user.company_id).where('email ~* ?', params[:term]).order(:last_name, :first_name).uniq

    @clients_arr = Array.new
    @clients.each do |client|
      label = ''
      desc = ''
      if client.first_name
        label += client.first_name
      end
      label += ' '
      if client.last_name
        label += client.last_name
      end
      if client.email
        desc += client.email
      end
      desc += ' '
      if client.phone
        desc += client.phone
      end
      @clients_arr.push({:label => label, :desc => desc, :value => client.to_json})
    end

    render :json => @clients_arr
  end

  def name_suggestion
    @clients = Client.where(company_id: current_user.company_id).where("CONCAT(first_name, ' ', last_name) ILIKE :s OR first_name ILIKE :s OR last_name ILIKE :s", :s => "%#{params[:term]}%").order(:last_name, :first_name).uniq

    @clients_arr = Array.new
    @clients.each do |client|
      label = ''
      desc = ''
      if client.first_name
        label += client.first_name
      end
      label += ' '
      if client.last_name
        label += client.last_name
      end
      if client.email
        desc += client.email
      end
      desc += ' '
      if client.phone
        desc += client.phone
      end
      @clients_arr.push({:label => label, :desc => desc, :value => client.to_json})
    end

    render :json => @clients_arr
  end

  def rut_suggestion
    search_rut = params[:term].gsub(/[.-]/, "")
    @clients = Client.where(company_id: current_user.company_id).where("replace(replace(identification_number, '.', ''), '-', '') ILIKE ?", "%#{search_rut}%").uniq

    @clients_arr = Array.new
    @clients.each do |client|
      label = ''
      desc = ''
      if client.first_name
        desc += client.first_name
      end
      desc += ' '
      if client.last_name
        desc += client.last_name
      end
      if client.identification_number
        label = client.identification_number
      end
      @clients_arr.push({:label => label, :desc => desc, :value => client.to_json})
    end

    render :json => @clients_arr
  end

  def client_loader
    @client = Client.where(identification_number: params[:term], company_id: params[:company_id]).first

    render :json => @client
  end

  def import
    message = Client.import(params[:file], current_user.company_id)
    redirect_to clients_path, notice: message
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:company_id, :email, :first_name, :last_name, :identification_number, :phone, :address, :district, :city, :age, :gender, :birth_day, :birth_month, :birth_year, :can_book)
    end

    def client_comment_params
      params.require(:client_comment).permit(:id, :client_id, :comment)
    end
end
