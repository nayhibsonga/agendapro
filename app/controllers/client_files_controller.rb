class ClientFilesController < ApplicationController
  before_action :set_client_file, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  load_and_authorize_resource

  respond_to :html, :json

  # GET /client_files
  # GET /client_files.json
  def index
    @client_files = ClientFile.all
  end

  # GET /client_files/1
  # GET /client_files/1.json
  def show
    
    json_response = []

    s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
    obj = s3_bucket.object(@client_file.full_path)
    is_image = false
    public_url = obj.public_url

    if !obj.content_type.index("image").nil?
      is_image = true
    end

    json_response << @client_file
    json_response << public_url
    json_response << is_image

    respond_with(@client_file) do |format|

      format.json {
        render json: json_response
      }

    end

  end

  # GET /client_files/new
  def new
    @client_file = ClientFile.new
  end

  # GET /client_files/1/edit
  def edit
  end

  # POST /client_files
  # POST /client_files.json
  def create
    @client_file = ClientFile.new(client_file_params)
    
    respond_with(@client_file) do |format|
      format.html { 
        flash[:notice] = "Archivo creado." if @client_file.save
        redirect_to client_files_path() 
      }
    end
  end

  # PATCH/PUT /client_files/1
  # PATCH/PUT /client_files/1.json
  def update
    respond_with(@client_file) do |format|
      format.html { 
        flash[:notice] = "Archivo editado." if @client_file.update(client_file_params)
        redirect_to client_files_path() 
      }
    end
  end

  # DELETE /client_files/1
  # DELETE /client_files/1.json
  def destroy
    
    respond_with(@client_file) do |format|
      if @client_file.destroy
        format.html { 
          flash[:notice] = "Archivo eliminado."
          redirect_to client_files_path() 
        }
        format.json {
          render json: @client_file
        }
      else
        format.html { 
          flash[:notice] = "Archivo no pudo ser eliminado."
          redirect_to client_files_path() 
        }
        format.json {
          render json: @client_file
        }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client_file
      @client_file = ClientFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_file_params
      params.require(:client_file).permit(:client_id, :name, :full_path, :public_url, :size, :description)
    end
end
