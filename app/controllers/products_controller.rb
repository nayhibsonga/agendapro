class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  before_action -> (source = "products") { verify_free_plan source }
  before_action :verify_blocked_status
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

  def company_reports

    @company = current_user.company

    @from = params[:from].to_datetime.beginning_of_day
    @to = params[:to].to_datetime.end_of_day

    #Get products ranking by price sum and item quantity in this period
    @products = []

    @company.products.each do |product|
      product_price_sum = 0
      product_quantity_sum = 0
      product.payment_products.where(payment_id: Payment.where(payment_date: @from..@to).pluck(:id)).each do |pp|
        product_quantity_sum += pp.quantity
        product_price_sum += pp.quantity * pp.price
      end
      product_tuple = [product, product_price_sum, product_quantity_sum]
      @products << product_tuple
    end

    #Get sellers ranking in this period

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

    emails = ""
    @location_product.stock_emails.each do |stock_email|
      if emails == ""
        emails = emails + stock_email.email
      else
        emails = emails + ", " + stock_email.email
      end
    end

    @response_array << emails

    render :json => @response_array

  end

  def set_alarm
    @location_product = LocationProduct.find(params[:location_product_id])
    @location_product.stock_limit = params[:stock_limit]
    @location_product.stock_emails.delete_all
    emails = []
    emails_arr = params[:alarm_email].split(",")
    emails_arr.each do |email|
      email_str = email.strip
      if email_str != ""
        new_stock_email = StockEmail.create(:location_product_id => @location_product.id, :email => email_str)
      end
    end
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
    message = "No se seleccionó archivo."
    filename_arr = params[:file].original_filename.split(".")
    if filename_arr.length > 0
      extension = filename_arr[filename_arr.length - 1]
      if extension == "csv" || extension == "xls"
        message = Product.import(params[:file], current_user.company_id, current_user)
      else
        message = "La extensión del archivo no es correcta. Sólo se pueden importar archivos xls y csv."
      end
    end
    redirect_to products_path, notice: message
  end

  def product_features
    
    respond_to do |format|
      format.html { render :partial => 'product_features' }
    end
  end

  def free_plan_landing

  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :price, :sku, :product_category_id, :product_brand_id, :product_display_id, :description, :comission_value, :comission_option, :cost, :internal_price, :location_products_attributes => [:id, :location_id, :stock])
    end
end
