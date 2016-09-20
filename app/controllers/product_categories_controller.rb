class ProductCategoriesController < ApplicationController
  before_action :set_product_category, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :json

  def index
    @product_categories = ProductCategory.where(company_id: current_user.company_id).order(:name)
    respond_with(@product_categories)
  end

  def show
    respond_with(@product_category)
  end

  def new
    @product_category = ProductCategory.new
    respond_with(@product_category)
  end

  def edit
  end

  def create
    @product_category = ProductCategory.new(product_category_params)
    @product_category.company_id = current_user.company_id
    @product_category.save
    respond_to do |format|
      format.json { render :json => @product_category }
    end
  end

  def update
    @product_category.update(product_category_params)
    respond_to do |format|
      format.json { render :json => @product_category }
    end
  end

  def destroy
    if @product_category.name == "Otros"
      render :json => { :errors => 'No es posible eliminar la categoría "Otros".' }, :status => 422
    else
      @products = Product.where(product_category_id: @product_category)
      @new_product_category = ProductCategory.where(company_id: @product_category.company_id, name: "Otros").first
      if @new_product_category.nil?
        @new_product_category = ProductCategory.create(name: "Otros", company_id: @product_category.company_id)
        @new_product_category.save
      end
      @products.each do |product|
        product.product_category = @new_product_category
        product.save
      end
      @product_category.destroy
      respond_to do |format|
        format.html { redirect_to product_categories_url }
        format.json { head :no_content }
      end
    end
  end

  def products
    @categories = ProductCategory.find(params[:categories_ids])
    @products = Product.where(product_category_id: @categories).joins(:product_category).order('product_categories.name asc').joins(:product_brand).order('product_brands.name asc').order(name: :asc)
    if params[:status] == "active"
      @products = @products.where(active: true)
    elsif params[:status] == "inactive"
      @products = @products.where(active: false)
    end
    render :json => @products
  end

  private
    def set_product_category
      @product_category = ProductCategory.find(params[:id])
    end

    def product_category_params
      params.require(:product_category).permit(:name)
    end
end
