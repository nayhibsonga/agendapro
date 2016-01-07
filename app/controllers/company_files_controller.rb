class CompanyFilesController < ApplicationController
  before_action :set_company_file, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  
  load_and_authorize_resource

  # GET /company_files
  # GET /company_files.json
  def index
    @company_files = CompanyFile.all
  end

  # GET /company_files/1
  # GET /company_files/1.json
  def show
  end

  # GET /company_files/new
  def new
    @company_file = CompanyFile.new
  end

  # GET /company_files/1/edit
  def edit
  end

  # POST /company_files
  # POST /company_files.json
  def create
    @company_file = CompanyFile.new(company_file_params)

    respond_to do |format|
      if @company_file.save
        format.html { redirect_to @company_file, notice: 'Company file was successfully created.' }
        format.json { render action: 'show', status: :created, location: @company_file }
      else
        format.html { render action: 'new' }
        format.json { render json: @company_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /company_files/1
  # PATCH/PUT /company_files/1.json
  def update
    respond_to do |format|
      if @company_file.update(company_file_params)
        format.html { redirect_to @company_file, notice: 'Company file was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /company_files/1
  # DELETE /company_files/1.json
  def destroy
    @company_file.destroy
    respond_to do |format|
      format.html { redirect_to company_files_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company_file
      @company_file = CompanyFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_file_params
      params.require(:company_file).permit(:company_id, :name, :full_path, :public_url, :size, :description)
    end
end
