class ProductDisplaysController < ApplicationController
  before_action :set_product_display, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :json

  def index
    @product_displays = ProductDisplay.where(company_id: current_user.company_id).order(:name)
    respond_with(@product_displays)
  end

  def show
    respond_with(@product_display)
  end

  def new
    @product_display = ProductDisplay.new
    respond_with(@product_display)
  end

  def edit
  end

  def create
    @product_display = ProductDisplay.new(product_display_params)
    @product_display.company_id = current_user.company_id
    @product_display.save
    respond_to do |format|
      format.json { render :json => @product_display }
    end
  end

  def update
    @product_display.update(product_display_params)
    respond_to do |format|
      format.json { render :json => @product_display }
    end
  end

  def destroy
    if @product_display.name == "Otros"
      render :json => { :errors => 'No es posible eliminar la categoría "Otros".' }, :status => 422
    else
      @products = Product.where(product_display_id: @product_display)
      @new_product_display = ProductDisplay.where(company_id: @product_display.company_id, name: "Otros").first
      if @new_product_display.nil?
        @new_product_display = ProductDisplay.create(name: "Otros", company_id: @product_display.company_id)
        @new_product_display.save
      end
      @products.each do |product|
        product.product_display = @new_product_display
        product.save
      end
      @product_display.destroy
      respond_to do |format|
        format.html { redirect_to product_displays_url }
        format.json { head :no_content }
      end
    end
  end

  private
    def set_product_display
      @product_display = ProductDisplay.find(params[:id])
    end

    def product_display_params
      params.require(:product_display).permit(:name)
    end
end
