class ProductBrandsController < ApplicationController
  before_action :set_product_brand, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :json

  def index
    @product_brands = ProductBrand.where(company_id: current_user.company_id).order(:name)
    respond_with(@product_brands)
  end

  def show
    respond_with(@product_brand)
  end

  def new
    @product_brand = ProductBrand.new
    respond_with(@product_brand)
  end

  def edit
  end

  def create
    @product_brand = ProductBrand.new(product_brand_params)
    @product_brand.company_id = current_user.company_id
    @product_brand.save
    respond_to do |format|
      format.json { render :json => @product_brand }
    end
  end

  def update
    @product_brand.update(product_brand_params)
    respond_to do |format|
      format.json { render :json => @product_brand }
    end
  end

  def destroy
    if @product_brand.name == "Otros"
      render :json => { :errors => 'No es posible eliminar la categoría "Otros".' }, :status => 422
    else
      @products = Product.where(product_brand_id: @product_brand)
      @new_product_brand = ProductBrand.where(company_id: @product_brand.company_id, name: "Otros").first
      if @new_product_brand.nil?
        @new_product_brand = ProductBrand.create(name: "Otros", company_id: @product_brand.company_id)
        @new_product_brand.save
      end
      @products.each do |product|
        product.product_brand = @new_product_brand
        product.save
      end
      @product_brand.destroy
      respond_to do |format|
        format.html { redirect_to product_brands_url }
        format.json { head :no_content }
      end
    end
  end

  private
    def set_product_brand
      @product_brand = ProductBrand.find(params[:id])
    end

    def product_brand_params
      params.require(:product_brand).permit(:name)
    end
end
