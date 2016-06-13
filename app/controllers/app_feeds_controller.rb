class ServiceCategoriesController < ApplicationController
  before_action :set_app_feed, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin", except: [:change_categories_order]
  load_and_authorize_resource

  # GET /service_categories
  # GET /service_categories.json
  def index
    @app_feeds = AppFeed.where(:company_id => current_user.company_id).order(:created_at)
  end

  # GET /service_categories/1
  # GET /service_categories/1.json
  def show
  end

  # GET /service_categories/new
  def new
    @app_feed = AppFeed.new
    @app_feed.company_id = current_user.company_id
  end

  # GET /service_categories/1/edit
  def edit
  end

  # POST /service_categories
  # POST /service_categories.json
  def create
    @app_feed = AppFeed.new(app_feed_params)

    respond_to do |format|
      if @app_feed.save
        format.html { redirect_to service_categories_path, notice: 'Aviso para App creado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @app_feed }
      else
        format.html { render action: 'new' }
        format.json { render json: @app_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /service_categories/1
  # PATCH/PUT /service_categories/1.json
  def update
    respond_to do |format|
      if @app_feed.update(app_feed_params)
        format.html { redirect_to service_categories_path, notice: 'Aviso para App actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @app_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_categories/1
  # DELETE /service_categories/1.json
  def destroy
    if @app_feed.name == "Otros"
      redirect_to service_categories_path, notice: 'No es posible eliminar la categoría "Otros".'
    end
    @services = Service.where(service_category_id: @app_feed)
    @bundles = Bundle.where(service_category_id: @app_feed)
    @new_service_category = AppFeed.where(company_id: @app_feed.company_id, name: "Otros").first
    if @new_service_category.nil?
      @new_service_category = AppFeed.create(name: "Otros", company_id: @app_feed.company_id)
      @new_service_category.save
    end
    @services.each do |service|
      service.service_category = @new_service_category
      service.save
    end
    @bundles.each do |bundle|
      bundle.service_category = @new_service_category
      bundle.save
    end
    @app_feed.destroy
    respond_to do |format|
      format.html { redirect_to service_categories_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_feed
      @app_feed = AppFeed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_feed_params
      params.require(:app_feed).permit(:title, :company_id, :subtitle, :body, :external_url, :image)
    end
end
