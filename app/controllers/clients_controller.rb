class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:client_loader]
  before_action :quick_add
  before_action -> (source = "clients") { verify_free_plan source }, except: [:history, :bookings_history, :check_sessions, :suggestion, :name_suggestion, :rut_suggestion, :new, :edit, :create, :update]
  before_action :verify_blocked_status, except: [:history, :bookings_history, :check_sessions, :suggestion, :name_suggestion, :rut_suggestion, :new, :edit, :create, :update]
  before_action :verify_premium_plan, only: [:files, :create_folder, :rename_folder, :delete_folder, :upload_file, :move_file, :edit_file]
  load_and_authorize_resource
  layout "admin"

  helper_method :sort_column, :sort_direction

  # GET /clients
  # GET /clients.json
  def index
    if mobile_request?
      @company = current_user.company
    end
    @monthly_mails = current_user.company.plan.monthly_mails
    @monthly_mails_sent = current_user.company.company_setting.monthly_mails
    @from_collection = current_user.company.company_from_email.where(confirmed: true)

    @locations = Location.where(company_id: current_user.company_id, active: true).order(:order, :name)
    @service_providers = ServiceProvider.where(company_id: current_user.company_id, active: true).order(:order, :public_name)
    @services = Service.where(company_id: current_user.company_id, active: true).order(:order, :name)

    if [:locations, :providers, :services, :range_from, :range_to].any? {|s| params.key?(s) && !params[s].blank? }
      attendance = if params[:attendance].blank? then true else params[:attendance] == 'true' end
      @clients = Client.accessible_by(current_ability).search(params[:search], current_user.company_id).filter_location(params[:locations], attendance).filter_provider(params[:providers], attendance).filter_service(params[:services], attendance).filter_gender(params[:gender]).filter_birthdate(params[:birth_from], params[:birth_to]).filter_status(params[:statuses]).filter_range(params[:range_from], params[:range_to], attendance).order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 25)

      @clients_export = Client.accessible_by(current_ability).search(params[:search], current_user.company_id).filter_location(params[:locations], attendance).filter_provider(params[:providers], attendance).filter_service(params[:services], attendance).filter_gender(params[:gender]).filter_birthdate(params[:birth_from], params[:birth_to]).filter_status(params[:statuses]).filter_range(params[:range_from], params[:range_to], attendance).order(sort_column + " " + sort_direction)
    else
      @clients = Client.accessible_by(current_ability).search(params[:search], current_user.company_id).filter_attendance(params[:attendance], current_user.company_id).filter_gender(params[:gender]).filter_birthdate(params[:birth_from], params[:birth_to]).filter_status(params[:statuses]).order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 25)

      @clients_export = Client.accessible_by(current_ability).search(params[:search], current_user.company_id).filter_attendance(params[:attendance], current_user.company_id).filter_gender(params[:gender]).filter_birthdate(params[:birth_from], params[:birth_to]).filter_status(params[:statuses]).order(sort_column + " " + sort_direction)
    end

    respond_to do |format|
      format.html
      format.csv
      format.xls
    end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show

    @services = Service.where(company_id: @client.company.id).accessible_by(current_ability)
    @service_providers = ServiceProvider.where(company_id: @client.company.id).accessible_by(current_ability)

    @start_date = DateTime.now - 2.weeks
    if @client.bookings.where('start < ?', DateTime.now).count > 0
      @start_date = @client.bookings.where('start < ?', DateTime.now).order('start desc').first.start
    end

    @end_date = DateTime.now
    if @client.bookings.where('start > ?', DateTime.now).count > 0
      @end_date = @client.bookings.where('start > ?', DateTime.now).order('start desc').first.start
    end

    @start_date = @start_date.strftime("%d/%m/%Y")
    @end_date = @end_date.strftime("%d/%m/%Y")

    logger.debug "Dates: "
    logger.debug @start_date
    logger.debug @end_date

  end

  def bookings_content

    @client = Client.find(params[:client_id])

    @from = params[:from].blank? ? Date.today : Date.parse(params[:from])
    @to = params[:to].blank? ? Date.today : Date.parse(params[:to])
    @service_ids = params[:service_ids] ? params[:service_ids].split(',') : Service.where(company_id: current_user.company_id).accessible_by(current_ability).pluck(:id)
    @service_provider_ids = params[:service_provider_ids] ? params[:service_provider_ids].split(',') : ServiceProvider.where(company_id: current_user.company_id).accessible_by(current_ability).pluck(:id)
    @status_ids = params[:status_ids] ? params[:status_ids].split(',') : Status.all.pluck(:id)

    @bookings = @client.bookings.where(start: @from.beginning_of_day..@to.end_of_day, service_id: @service_ids, service_provider_id: @service_provider_ids, status_id: @status_ids).where('is_session = false or (is_session = true and is_session_booked = true)').order(start: :desc).paginate(:page => params[:page], :per_page => 25)

    @booked = @bookings.where(status: Status.find_by(name: 'Reservado')).count
    @confirmed = @bookings.where(status: Status.find_by(name: 'Confirmado')).count
    @attended = @bookings.where(status: Status.find_by(name: 'Asiste')).count
    @payed = @bookings.where('payment_id is not null').count
    @cancelled = @bookings.where(status: Status.find_by(name: 'Cancelado')).count
    @notAttended = @bookings.where(status: Status.find_by(name: 'No Asiste')).count

    render "_bookings_content", layout: false

  end

  # GET /clients/new
  def new
    @activeBookings = Array.new
    @lastBookings = Array.new
    @client = Client.new
    @client_comment = ClientComment.new
    @company = current_user.company
    @folders = []
    if mobile_request?
      @company = current_user.company
    end
  end

  # GET /clients/1/edit
  def edit

    @company = @client.company

    @activeBookings = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(:client_id => @client).where("start > ?", DateTime.now).order(start: :asc)
    @lastBookings = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(:client_id => @client).where("start <= ?", DateTime.now).order(start: :desc)
    @next_bookings = Booking

    @preSessionBookings = SessionBooking.where(:client_id => @client)

    @sessionBookings = []

    @files = @client.client_files.order('updated_at desc').limit(5)

    s3 = Aws::S3::Client.new
    resp = s3.list_objects(bucket: ENV['S3_BUCKET'], prefix: 'companies/' +  @client.company_id.to_s + '/clients/' + @client.id.to_s + '/', delimiter: '/')

    @s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

    folders_prefixes = resp.common_prefixes
    @folders = []

    folders_prefixes.each do |folder|
      sub_str = folder.prefix[0, folder.prefix.rindex("/")]
      @folders << sub_str[sub_str.rindex("/") + 1, sub_str.length]
    end

    @preSessionBookings.each do |session_booking|

      include_sb = false

      if session_booking.sessions_taken && session_booking.sessions_amount && session_booking.sessions_taken < session_booking.sessions_amount
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
        @client.save_attributes(params)
        format.html { redirect_to clients_path, notice: 'Cliente creado exitosamente.' }
        format.json { render action: 'edit', status: :created, location: @client }
      else
        format.html {
          @company = current_user.company
          @activeBookings = Array.new
          @lastBookings = Array.new
          @client_comment = ClientComment.new
          @sessionBookings = []
          render action: 'new' }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)

        #Check for custom attributes

        @client.save_attributes(params)

        format.html { redirect_to edit_client_path(id: @client.id), notice: 'Cliente actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html {
          @activeBookings = Booking.where(:client_id => @client).where("start > ?", DateTime.now).order(start: :asc)
          @lastBookings = Booking.where(:client_id => @client).where("start <= ?", DateTime.now).order(start: :desc)
          @next_bookings = Booking
          @client_comment = ClientComment.new
          @client_comments = ClientComment.where(client_id: @client).order(created_at: :desc)
          @company = current_user.company

          @preSessionBookings = SessionBooking.where(:client_id => @client)

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
          render action: 'edit' }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def history
    @client = Client.find(params[:id])
    @bookings = @client.bookings.where('is_session = false or (is_session = true and is_session_booked = true)').order(start: :desc)
  end

  def bookings_history
    client = Client.find(params[:id])
    bookings = []
    client.bookings.where('start < ?', Time.now).where('is_session = false or (is_session = true and is_session_booked = true)').order(start: :desc).limit(10).each do |booking|
      bookings.push( { start: booking.start, service: booking.service.name, provider: booking.service_provider.public_name, status: booking.status.name, notes: booking.notes, comment: booking.company_comment } )
    end

    render :json => bookings
  end

  def check_sessions

    @respArr = []
    @session_bookings = []

    client = Client.find(params[:id])
    service = Service.find(params[:service_id])
    session_bookings = SessionBooking.where(:client_id => client.id, :service_id => service.id)

    session_bookings.each do |session_booking|
      if session_booking.sessions_amount > session_booking.sessions_taken
        sessions_hash = session_booking.attributes
        sessions_hash["sessions_total"] = session_booking.sessions_amount
        @session_bookings << sessions_hash
      end
    end

    @respArr << service
    @respArr << @session_bookings

    render :json => @respArr

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
    attendance = params[:attendance].blank? || params[:attendance] == 'true'
    @from_collection = current_user.company.company_from_email.where(confirmed: true)
    if [:locations, :providers, :services, :range_from, :range_to].any? {|s| params.key?(s) && !params[s].blank? }
      attendance = if params[:attendance].blank? then true else params[:attendance] == 'true' end
      mail_list = Client.accessible_by(current_ability).search(params[:search], current_user.company_id).filter_location(params[:locations], attendance).filter_provider(params[:providers], attendance).filter_service(params[:services], attendance).filter_gender(params[:gender]).filter_birthdate(params[:birth_from], params[:birth_to]).filter_status(params[:statuses]).filter_range(params[:range_from], params[:range_to], attendance).order(:last_name, :first_name).pluck(:email).uniq
    else
      mail_list = Client.accessible_by(current_ability).search(params[:search], current_user.company_id).filter_attendance(params[:attendance], current_user.company_id).filter_gender(params[:gender]).filter_birthdate(params[:birth_from], params[:birth_to]).filter_status(params[:statuses]).order(:last_name, :first_name).pluck(:email).uniq
    end

    @tmpl = 'basic'

    template_selection if current_user.company.is_plan_capable("Premium") || Rails.env === 'development' && params[:full]

    tmp_to = Array.new
    mail_list.each do |email|
      tmp_to.push(email) if email=~ /([^\s]+)@([^\s]+)/
    end
    @to = tmp_to.join(', ')
  end

  def send_mail
    # Sumar mails eviados
    current_sent = current_user.company.company_setting.monthly_mails
    sent_to = params[:to].split(',').each { |mail| mail.strip! }
    sent_now = sent_to.length
    current_sent + sent_now >= 0 ? new_mails = current_sent + sent_now : new_mails = 0
    current_user.company.company_setting.update_attributes :monthly_mails => (new_mails)
    attachments = params[:attachment]
    subject = params[:subject]
    message = params[:message]
    sent_from = params[:from]

    Thread.new do
      clients = Array.new
      sent_to.each do |client_mail|
        client_info = {
          :email => client_mail,
          :type => 'bcc'
        }
        clients.push(client_info)
      end

      if attachments
        attachment = {
          :type => attachments.content_type,
          :name => attachments.original_filename,
          :content => Base64.encode64(File.read(attachments.tempfile))
        }
      else
        attachment = {}
      end

      ClientMailer.send_client_mail(current_user, clients, subject, message, attachment, sent_from)

      # Close database connection
      ActiveRecord::Base.connection.close
      Thread.exit
    end

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

      @clients_arr.push({:label => label, :desc => desc, :value => client.to_json, :custom_attributes => client.get_custom_attributes})
    end

    render :json => @clients_arr
  end

  def name_suggestion
    search_array = params[:term].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').split(' ')
    search_array2 = []
    search_array.each do |item|
      if item.length > 2
        search_array2.push('%'+item+'%')
      end
    end
    @clients1 = Client.where(company_id: current_user.company_id).where('first_name ILIKE ANY ( array[:s] )', :s => search_array2).where('last_name ILIKE ANY ( array[:s] )', :s => search_array2).pluck(:id).uniq
    @clients2 = Client.where(company_id: current_user.company_id).where("CONCAT(unaccent(first_name), ' ', unaccent(last_name)) ILIKE unaccent(:s) OR unaccent(first_name) ILIKE unaccent(:s) OR unaccent(last_name) ILIKE unaccent(:s)", :s => "%#{params[:term]}%").pluck(:id).uniq

    @clients = Client.where(id: (@clients1 + @clients2).uniq).order(:last_name, :first_name)

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
      @clients_arr.push({:label => label, :desc => desc, :value => client.to_json, :custom_attributes => client.get_custom_attributes})
    end

    render :json => @clients_arr
  end

  def rut_suggestion
    search_rut = params[:term].gsub(/[.-]/, "")
    @clients = Client.where(company_id: current_user.company_id).where("replace(replace(identification_number, '.', ''), '-', '') ILIKE ?", "%#{search_rut}%").order(:last_name, :first_name).uniq

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
      @clients_arr.push({:label => label, :desc => desc, :value => client.to_json, :custom_attributes => client.get_custom_attributes})
    end

    render :json => @clients_arr
  end

  def client_loader
    @client = Client.where(identification_number: params[:term], company_id: params[:company_id]).first

    render :json => @client
  end

  def import
    message = "No se seleccionó archivo."
    filename_arr = params[:file].original_filename.split(".")
    if filename_arr.length > 0
      extension = filename_arr[filename_arr.length - 1]
      if extension == "csv" || extension == "xls"
        message = Client.import(params[:file], current_user.company_id)
      else
        message = "La extensión del archivo no es correcta. Sólo se pueden importar archivos xls y csv."
      end
    end
    redirect_to clients_path, notice: message
  end

  def upload_file

    upload_origin = params[:origin]

    @client = Client.find(params[:client_id])

    if(params[:file].size/1024/1024 > 25)
      if upload_origin == "edit_client"
        redirect_to edit_client_path(id: @client.id), alert: 'Tamaño de archivo no permitido'
      else
        redirect_to get_client_files_path(client_id: @client.id), alert: 'Tamaño de archivo no permitido'
      end
      return
    end

    file_name = params[:file_name]
    folder_name = params[:folder_name]
    logger.debug "File name: " + params[:file].original_filename
    file_extension = params[:file].original_filename[params[:file].original_filename.rindex(".") + 1, params[:file].original_filename.length]
    content_type = params[:file].content_type

    file_description = ""
    if !params[:file_description].blank?
      file_description = params[:file_description]
    end

    if !params[:new_folder_name].blank? && folder_name == "select"
      folder_name = params[:new_folder_name]
    end

    full_name = 'companies/' +  @client.company_id.to_s + '/clients/' + @client.id.to_s + '/' + folder_name + '/' + params[:file].original_filename

    s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

    obj = s3_bucket.object(full_name)

    if !obj.exists?
      obj.upload_file(params[:file].path(), {acl: 'public-read', content_type: content_type})
    else
      full_name = 'companies/' +  @client.company_id.to_s + '/clients/' + @client.id.to_s + '/' + folder_name + '/' + DateTime.now.to_i.to_s + '_' + params[:file].original_filename
      obj = s3_bucket.object(full_name)
      obj.upload_file(params[:file].path(), {acl: 'public-read', content_type: content_type})
    end

    @client_file = ClientFile.new(client_id: @client.id, name: file_name, full_path: full_name, public_url: obj.public_url, size: obj.size, description: file_description, folder: folder_name)


    # Save the upload
    if @client_file.save
      if upload_origin == "edit_client"
        redirect_to edit_client_path(id: @client.id), notice: 'Archivo guardado correctamente'
      else
        redirect_to get_client_files_path(client_id: @client.id), notice: 'Archivo guardado correctamente'
      end
    else
      obj.delete
      if upload_origin == "edit_client"
        redirect_to edit_client_path(id: @client.id), alert: 'No se pudo guardar el archivo'
      else
        redirect_to get_client_files_path(client_id: @client.id), alert: 'No se pudo guardar el archivo'
      end
    end

  end

  def create_folder

    @client = Client.find(params[:client_id])

    full_name = 'companies/' +  @client.company_id.to_s + '/clients/' + @client.id.to_s + '/' + params[:folder_name] + '/'

    #s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
    s3 = Aws::S3::Client.new
    s3.put_object(bucket: ENV['S3_BUCKET'], key: full_name)
      #obj = s3_bucket.object(full_name)

    redirect_to get_client_files_path(client_id: @client.id), notice: 'Carpeta creada correctamente'

  end

  def rename_folder

    @company = current_user.company
    @client = Client.find(params[:client_id])

    new_folder_name = params[:new_folder_name]
    old_folder_name = params[:old_folder_name]

    #Do nothing if same folder
    if new_folder_name == old_folder_name
      redirect_to get_client_files_path(client_id: @client.id), notice: 'Carpeta renombrada correctamente'
      return
    end

    s3 = Aws::S3::Client.new

    old_folder_path = 'companies/' +  @company.id.to_s + '/clients/' + @client.id.to_s + '/' + old_folder_name + '/'
    new_folder_path = 'companies/' +  @company.id.to_s + '/clients/' + @client.id.to_s + '/' + new_folder_name + '/'

    #Create new folder in case there are no files
    s3.put_object(bucket: ENV['S3_BUCKET'], key: new_folder_path)

    s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

    #Move each object to new folder
    @client.client_files.where(folder: old_folder_name).each do |client_file|
      obj = s3_bucket.object(client_file.full_path)

      obj_name = obj.key[obj.key.rindex("/")+1, obj.key.length]

      obj.move_to({bucket: ENV['S3_BUCKET'], key: new_folder_path + obj_name}, {acl: 'public-read', content_type: content_type})

      client_file.full_path = new_folder_path + obj_name
      client_file.public_url = obj.public_url
      client_file.folder = new_folder_name
      client_file.save

    end

    #Delete old folder
    old_folder = s3_bucket.object(old_folder_path)
    old_folder.delete

    redirect_to get_client_files_path(client_id: @client.id), notice: 'Carpeta renombrada correctamente'

  end

  def delete_folder

    @company = current_user.company
    @client = Client.find(params[:client_id])

    folder_name = params[:folder_name]

    s3 = Aws::S3::Client.new

    folder_path = 'companies/' +  @company.id.to_s + '/clients/' + @client.id.to_s + '/' + folder_name + '/'


    s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

    #Move each object to new folder
    @client.client_files.where(folder: folder_name).each do |client_file|

      client_file.destroy

    end

    #Delete old folder
    old_folder = s3_bucket.object(folder_path)
    if old_folder.exists?
      old_folder.delete
    end

    redirect_to get_client_files_path(client_id: @client.id), notice: 'Carpeta eliminada correctamente'

  end

  def move_file

    @company = current_user.company
    @client_file = ClientFile.find(params[:client_file_id])
    @client = Client.find(params[:client_id])

    new_folder_name = params[:folder_name]

    #Do nothing if same folder
    if new_folder_name == @client_file.folder
      redirect_to get_client_files_path(client_id: @client.id), notice: 'Archivo movido correctamente'
      return
    end

    new_folder_path = 'companies/' +  @company.id.to_s + '/clients/' + @client.id.to_s + '/' + new_folder_name + '/'

    s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

    obj = s3_bucket.object(@client_file.full_path)

    obj_name = obj.key[obj.key.rindex("/")+1, obj.key.length]

    obj.move_to({bucket: ENV['S3_BUCKET'], key: new_folder_path + obj_name}, {acl: 'public-read', content_type: content_type})

    old_folder_path = 'companies/' +  @company.id.to_s + '/clients/' + @client.id.to_s + '/' + @client_file.folder + '/'
      old_folder_obj = s3_bucket.object(old_folder_path)

      logger.debug "Path: " + old_folder_path
      logger.debug "Exists? " + old_folder_obj.exists?.to_s

      if !old_folder_obj.exists?
        s3 = Aws::S3::Client.new
      s3.put_object(bucket: ENV['S3_BUCKET'], key: old_folder_path)
      end

    @client_file.full_path = new_folder_path + obj_name
    @client_file.public_url = obj.public_url
    @client_file.folder = new_folder_name

    if @client_file.save
      redirect_to get_client_files_path(client_id: @client.id), notice: 'Archivo movido correctamente'
      else
      redirect_to get_client_files_path(client_id: @client.id), alert: 'Error al mover el archivo'
    end

  end

  def edit_file

    @company = current_user.company

    @client_file = ClientFile.find(params[:client_file_id])
    @client = Client.find(params[:client_id])

    @client_file.name = params[:file_name]
    @client_file.description = params[:file_description]

    folder_name = params[:folder_name]

    if !params[:new_folder_name].blank? && folder_name == "select"
        folder_name = params[:new_folder_name]
      end

    if folder_name != @client_file.folder

      new_folder_name = folder_name

      new_folder_path = 'companies/' + @company.id.to_s + '/clients/' + @client.id.to_s + '/' + new_folder_name + '/'

      s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

      obj = s3_bucket.object(@client_file.full_path)

      obj_name = obj.key[obj.key.rindex("/")+1, obj.key.length]

      obj.move_to({bucket: ENV['S3_BUCKET'], key: new_folder_path + obj_name}, {acl: 'public-read', content_type: content_type})

      old_folder_path = 'companies/' +  @company.id.to_s + '/clients/' + @client.id.to_s + '/' + @client_file.folder + '/'
        old_folder_obj = s3_bucket.object(old_folder_path)

        logger.debug "Path: " + old_folder_path
        logger.debug "Exists? " + old_folder_obj.exists?.to_s

        if !old_folder_obj.exists?
          s3 = Aws::S3::Client.new
        s3.put_object(bucket: ENV['S3_BUCKET'], key: old_folder_path)
        end


      @client_file.full_path = new_folder_path + obj_name
      @client_file.public_url = obj.public_url
      @client_file.folder = new_folder_name

    end

    if @client_file.save
      redirect_to get_client_files_path(client_id: @client.id), notice: 'Archivo editado correctamente'
      else
        redirect_to get_client_files_path(client_id: @client.id), alert: 'Error al mover el archivo'
    end

  end

  def files

    @client = Client.find(params[:client_id])

    s3 = Aws::S3::Client.new
    resp = s3.list_objects(bucket: ENV['S3_BUCKET'], prefix: 'companies/' +  @client.company_id.to_s + '/clients/' + @client.id.to_s + '/', delimiter: '/')

    @s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

    folders_prefixes = resp.common_prefixes
    @folders = []

    folders_prefixes.each do |folder|
      sub_str = folder.prefix[0, folder.prefix.rindex("/")]
      @folders << sub_str[sub_str.rindex("/") + 1, sub_str.length]
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
      if mobile_request?
        @company = current_user.company
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:company_id, :email, :first_name, :last_name, :identification_number, :phone, :address, :district, :city, :age, :gender, :birth_day, :birth_month, :birth_year, :can_book, :record, :second_phone)
    end

    def client_comment_params
      params.require(:client_comment).permit(:id, :client_id, :comment)
    end

    def sort_column
      Client.column_names.include?(params[:sort]) ? params[:sort] : "last_name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def template_selection
      @tmpl = 'full'
      @templates = Email::Template.all.order(id: :asc)
      @saved = Email::Content.includes(:template).of_company(current_user.company)
    end

end
