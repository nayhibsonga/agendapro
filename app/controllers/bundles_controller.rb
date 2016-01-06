class BundlesController < ApplicationController
  before_action :set_bundle, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource


  respond_to :html

  def index
    @bundles = Bundle.all
    respond_with(@bundles)
  end

  def show
    respond_with(@bundle)
  end

  def new
    @bundle = Bundle.new
    service_bundles = @bundle.service_bundles.build
    respond_with(@bundle)
  end

  def edit
  end

  def create
    @bundle = Bundle.new(bundle_params)
    if current_user.role_id != Role.find_by_name("Super Admin").id
      @bundle.company_id = current_user.company_id
    end
    respond_to do |format|
      if @bundle.save
        format.html { redirect_to services_path, notice: 'Paquete de Servicios creado exitosamente.' }
        format.json { render :json => @bundle }
      else
        format.html { render action: 'edit' }
        format.json { render :json => { :errors => @bundle.errors.full_messages }, :status => 422 }
      end
    end
  end

  def update
    respond_to do |format|
      if @bundle.update(bundle_params)
        format.html { redirect_to services_path, notice: 'Paquete de Servicios actualizado exitosamente.' }
        format.json { render :json => @bundle }
      else
        format.html { render action: 'edit' }
        format.json { render :json => { :errors => @bundle.errors.full_messages }, :status => 422 }
      end
    end
  end

  def destroy
    @bundle.destroy
    redirect_to services_path, notice: 'Paquete de servicios eliminado exitosamente.'
  end

  private
    def set_bundle
      @bundle = Bundle.find(params[:id])
    end

    def bundle_params
      params.require(:bundle).permit(:name, :price, :service_category_id, :show_price, :description, service_bundles_attributes: [:id, :service_id, :price, :_destroy])
    end
end
