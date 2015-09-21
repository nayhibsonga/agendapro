class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :html, :json, :xls, :csv

  def index
    @products = Product.where(company_id: current_user.company_id).order(:product_category_id, :product_brand_id, :name)
    @pre_xls_locations = Location.where(company_id: current_user.company_id, active: true).order(:id)

    if current_user.role_id != Role.find_by_name("Administrador General").id
      @xls_locations = []
      @pre_xls_locations.each do |location|
        if current_user.locations.pluck(:id).include?(location.id)
          @xls_locations << location
        end
      end
    else
       @xls_locations = @pre_xls_locations
    end

    @product_category = ProductCategory.new
    @product_brand = ProductBrand.new
    @product_display = ProductDisplay.new
    @product_categories = ProductCategory.where(company_id: current_user.company_id).order(:name)
    @product_brands = ProductBrand.where(company_id: current_user.company_id).order(:name)
    @product_displays = ProductDisplay.where(company_id: current_user.company_id).order(:name)

    respond_with(@products)
  end

  def show
    respond_with(@product)
  end

  def new
    if ProductCategory.where(company_id: current_user.company_id).count == 0
      ProductCategory.create(name: "Otros", company_id: current_user.company_id)
    end
    @product_category = ProductCategory.new
    @product_brand = ProductBrand.new
    @product_display = ProductDisplay.new
    @product = Product.new
    @product.location_products.build
    @product_categories = ProductCategory.where(company_id: current_user.company_id).order(:name)
    @product_brands = ProductBrand.where(company_id: current_user.company_id).order(:name)
    @product_displays = ProductDisplay.where(company_id: current_user.company_id).order(:name)
    @locations = Location.where(company_id: current_user.company_id, active: true).order(:order, :name)
    respond_with(@product)
  end

  def edit
    @product_category = ProductCategory.new
    @product_brand = ProductBrand.new
    @product_display = ProductDisplay.new
    @product_categories = ProductCategory.where(company_id: current_user.company_id).order(:name)
    @product_brands = ProductBrand.where(company_id: current_user.company_id).order(:name)
    @product_displays = ProductDisplay.where(company_id: current_user.company_id).order(:name)
    @locations = Location.where(company_id: current_user.company_id, active: true).order(:order, :name)
  end

  def create

    @product = Product.new(product_params)
    @product.company_id = current_user.company_id
    @product.save

    loc_prods = JSON.parse(params[:location_products], symbolize_names: true)

    loc_prods.each do |loc_prod|
      location_product = LocationProduct.create(:location_id => loc_prod[:location_id], :product_id => @product.id, :stock => loc_prod[:stock])
    end

    respond_with(@product)
  end

  def update
    
    @product = Product.find(params[:id])
    respond_to do |format|
      if @product.update(product_params)
        
        loc_prods = JSON.parse(params[:location_products], symbolize_names: true)

        loc_prods.each do |loc_prod|
          location_product = LocationProduct.where(:location_id => loc_prod[:location_id], :product_id => @product.id).first
          location_product.stock = loc_prod[:stock]
          location_product.save
        end

        format.html { redirect_to products_path, notice: 'Producto actualizado exitosamente.' }
        format.json { render :json => @product }
      else
        format.html { redirect_to products_path, alert: 'No se pudo guardar el producto.' }
        format.json { render :json => { :errors => @product.errors.full_messages }, :status => 422 }
      end
    end
  end

  def destroy
    @product.destroy
    respond_with(@product)
  end

  def alarm_form
    @location_product = LocationProduct.find(params[:location_product_id])
    @location = @location_product.location

    @response_array = []

    if @location_product.stock_limit.nil?
      @response_array << @location.stock_alarm_setting.default_stock_limit
    else
      @response_array << @location_product.stock_limit
    end

    if @location_product.alarm_email.nil?
      @response_array << @location.stock_alarm_setting.email
    else
      @response_array << @location_product.alarm_email
    end

    render :json => @response_array

  end

  def set_alarm
    @location_product = LocationProduct.find(params[:location_product_id])
    @location_product.stock_limit = params[:stock_limit]
    @location_product.alarm_email = params[:alarm_email]
    @response_array = []
    if @location_product.save
      @response_array << "ok"
      @response_array << @location_product
    else
      @response_array << "error"
      @response_array << @location_product.errors.full_messages
    end
    render :json => @response_array
  end

  def import
    message = Product.import(params[:file], current_user.company_id, current_user)
    redirect_to products_path, notice: message
  end

  def product_features
    
    respond_to do |format|
      format.html { render :partial => 'product_features' }
    end
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :price, :sku, :product_category_id, :product_brand_id, :product_display_id, :description, :comission_value, :comission_option, :cost, :internal_price, :location_products_attributes => [:id, :location_id, :stock])
    end
end
