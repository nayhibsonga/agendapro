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

  def stats

    @company = current_user.company

    loc_status = "active"

    if params[:loc_status].blank? || params[:loc_status] == "all"
      loc_status = "all"
    elsif params[:loc_status] == "inactive"
      loc_status = "inactive"
    end

    @locations = @company.locations

    if current_user.role_id != Role.find_by_name("Administrador General").id
      @locations = current_user.locations
    end

    if loc_status == "active"
      @locations = @locations.where(active: true)
    elsif loc_status == "inactive"
      @locations = @locations.where(active: false)
    end

  end

  def locations_stats
    @company = current_user.company

    @locations = Location.find(params[:location_ids])

    @from = params[:from].to_datetime.beginning_of_day
    @to = params[:to].to_datetime.end_of_day

    @price_total = 0
    @quantity_total = 0

    #Get products ranking by price sum and item quantity in this period
    @products = []

    @company.products.each do |product|
      product_price_sum = 0
      product_quantity_sum = 0
      product.payment_products.where(payment_id: Payment.where(payment_date: @from..@to, location_id: params[:location_ids]).pluck(:id)).each do |pp|
        product_quantity_sum += pp.quantity
        product_price_sum += pp.quantity * pp.price
      end
      product_tuple = [product, product_price_sum, product_quantity_sum]
      @price_total += product_price_sum
      @quantity_total += product_quantity_sum
      @products << product_tuple
    end

    #Get provider sellers ranking in this period
    @provider_sellers = []
    @company.service_providers.each do |service_provider|
      product_price_sum = 0
      product_quantity_sum = 0
      PaymentProduct.where(payment_id: Payment.where(payment_date: @from..@to, location_id: params[:location_ids]).pluck(:id), seller_type: 0, seller_id: service_provider.id).each do |pp|
        product_quantity_sum += pp.quantity
        product_price_sum += pp.quantity * pp.price
      end
      provider_tuple = [service_provider, product_price_sum, product_quantity_sum]
      @provider_sellers << provider_tuple
    end

    #Get user sellers ranking in this period
    @user_sellers = []
    @company.users.each do |user|
      product_price_sum = 0
      product_quantity_sum = 0
      PaymentProduct.where(payment_id: Payment.where(payment_date: @from..@to, location_id: params[:location_ids]).pluck(:id), seller_type: 1, seller_id: user.id).each do |pp|
        product_quantity_sum += pp.quantity
        product_price_sum += pp.quantity * pp.price
      end
      user_tuple = [user, product_price_sum, product_quantity_sum]
      @user_sellers << user_tuple
    end

    @cashier_sellers = []
    @company.cashiers.each do |cashier|
      product_price_sum = 0
      product_quantity_sum = 0
      PaymentProduct.where(payment_id: Payment.where(payment_date: @from..@to, location_id: params[:location_ids]).pluck(:id), seller_type: 2, seller_id: cashier.id).each do |pp|
        product_quantity_sum += pp.quantity
        product_price_sum += pp.quantity * pp.price
      end
      cashier_tuple = [cashier, product_price_sum, product_quantity_sum]
      @cashier_sellers << cashier_tuple
    end

    @sellers = @provider_sellers + @user_sellers + @cashier_sellers

    respond_to do |format|
      format.html { render :partial => 'locations_stats' }
      format.json { render :json => @products }
    end

  end

  def seller_history

    @from = params[:from].to_datetime.beginning_of_day
    @to = params[:to].to_datetime.end_of_day

    @locations = Location.find(params[:location_ids])

    #json_response = []
    @status = "ok"

    if params[:seller_type].blank? || params[:seller_type].to_i > 2 || params[:seller_id].blank?
      @status = "error"
    end

    @seller = nil
    if params[:seller_type].to_i == 0
      @seller = ServiceProvider.find(params[:seller_id])
    elsif params[:seller_type].to_i == 1
      @seller = User.find(params[:seller_id])
    else
      @seller = Cashier.find(params[:seller_id])
    end

    @payment_products = PaymentProduct.where(payment_id: Payment.where(payment_date: @from..@to, location_id: params[:location_ids]), seller_type: params[:seller_type], seller_id: params[:seller_id]).order('(quantity * price) desc')

    respond_to do |format|
      format.html { render :partial => 'seller_history' }
      format.json { render :json => @payment_products }
    end

  end

  def product_history

    @product = Product.find(params[:product_id])

    @from = params[:from].to_datetime.beginning_of_day
    @to = params[:to].to_datetime.end_of_day

    @locations = Location.find(params[:location_ids])

    #json_response = []
    @status = "ok"

    if params[:product_id].blank?
      @status = "error"
    end

    @payment_products = PaymentProduct.where(payment_id: Payment.where(payment_date: @from..@to, location_id: params[:location_ids]), product_id: params[:product_id]).order('(quantity * price) desc')

    respond_to do |format|
      format.html { render :partial => 'product_history' }
      format.json { render :json => @payment_products }
    end

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
          old_stock = location_product.stock
          location_product.stock = loc_prod[:stock]
          if location_product.save
            ProductLog.create(product_id: @product.id, location_id: loc_prod[:location_id], user_id: current_user.id, change: "Incremento de " + old_stock.to_s + " a " + location_product.stock.to_s, cause: "Edición manual de producto.")
          end
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
      if extension == "csv" || extension == "xls" || extension == "xlsx" || extension == "xlsm" || extension == "ods" || extension == "xml"
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

  def stock_change

    @status = "ok"
    @type = params[:type]
    @product = Product.find(params[:product_id])
    @message = ""

    @locations = []
    if params[:location_id].to_i == 0
      if current_user.role == Role.find_by_name("Administrador Local")
        if current_user.locations.order(:id).pluck(:id) != current_user.company.locations.order(:id).pluck(:id)
          @status = "error"
          @message = "Lo sentimos, no tienes los permisos suficientes para modificar el stock de los locales elegidos."
        end
      end
      @locations = current_user.company.locations.where(active: true)
    else
      @locations << Location.find(params[:location_id])
    end

    respond_to do |format|
      format.html { render :partial => 'stock_change' }
      format.json { render json: @locations }
    end

  end

  def update_stock

    product = Product.find(params[:product_id])
    json_response = []
    errors = []

    json_response[0] = "ok"

    if params[:stock_change_type] == "add"
      current_user.company.locations.each do |location|
        loc_str = "location_" + location.id.to_s
        loc_str = loc_str.to_sym
        if !params[loc_str].blank? && params[loc_str].to_i > 0
          location_product = LocationProduct.where(location_id: location.id, product_id: product.id).first
          old_stock = location_product.stock
          location_product.stock += params[loc_str].to_i
          if !location_product.save
            errors << location_product.errors
            json_response[0] = "error"
          else
            cause = "Cambio de stock desde administrador."
            if !params[:notes].blank?
              cause += " Comentario: " + params[:notes]
            else
              cause += " Sin comentarios."
            end
            ProductLog.create(product_id: product.id, location_id: location.id, user_id: current_user.id, change: "Incremento de " + old_stock.to_s + " a " + location_product.stock.to_s, cause: cause)
          end
        end
      end
    else
      current_user.company.locations.each do |location|
        loc_str = "location_" + location.id.to_s
        loc_str = loc_str.to_sym
        if !params[loc_str].blank? && params[loc_str].to_i > 0
          location_product = LocationProduct.where(location_id: location.id, product_id: product.id).first
          old_stock = location_product.stock
          location_product.stock -= params[loc_str].to_i
          if location_product.stock < 0
            location_product.stock = 0
          end
          if !location_product.save
            errors << location_product.errors
            json_response[0] = "error"
          else
            cause = "Cambio de stock desde administrador."
            if !params[:notes].blank?
              cause += " Comentario: " + params[:notes]
            else
              cause += " Sin comentarios."
            end
            ProductLog.create(product_id: product.id, location_id: location.id, user_id: current_user.id, change: "Decremento de " + old_stock.to_s + " a " + location_product.stock.to_s, cause: cause)
          end
        end
      end
    end

    json_response[1] = errors

    render :json => json_response

  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :price, :sku, :product_category_id, :product_brand_id, :product_display_id, :description, :comission_value, :comission_option, :cost, :internal_price, :location_products_attributes => [:id, :location_id, :stock])
    end
end
