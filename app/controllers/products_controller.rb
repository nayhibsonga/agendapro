class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :html, :json

  def index
    @products = Product.where(company_id: current_user.company_id).order(:product_category_id, :name)
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
    @product = Product.new
    @product.location_products.build
    @product_categories = ProductCategory.where(company_id: current_user.company_id).order(:name)
    @locations = Location.where(company_id: current_user.company_id, active: true).order(:order)
    respond_with(@product)
  end

  def edit
    @product_category = ProductCategory.new
    @product_categories = ProductCategory.where(company_id: current_user.company_id).order(:name)
    @locations = Location.where(company_id: current_user.company_id, active: true).order(:order)
  end

  def create
    @product = Product.new(product_params)
    @product.company_id = current_user.company_id
    @product.save
    respond_with(@product)
  end

  def update
    @location_products = Product.find(params[:id]).location_products
    @location_products.each do |location_product|
      location_product.product_id = nil
      location_product.save
    end
    @product = Product.find(params[:id])
    respond_to do |format|
      if @product.update(product_params)
        @location_products.destroy_all
        format.html { redirect_to products_path, notice: 'Producto actualizado exitosamente.' }
        format.json { render :json => @product }
      else
        @location_products.each do |location_product|
          location_product.product_id = @product.id
          location_product.save
        end
        format.html { redirect_to products_path, alert: 'No se pudo guardar el producto.' }
        format.json { render :json => { :errors => @product.errors.full_messages }, :status => 422 }
      end
    end
  end

  def destroy
    @product.destroy
    respond_with(@product)
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :price, :sku, :product_category_id, :description, :comission_value, :comission_option, :location_products_attributes => [:id, :location_id, :stock])
    end
end
