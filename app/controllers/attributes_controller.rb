class AttributesController < ApplicationController
  before_action :set_attribute, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @attributes = Attribute.all
    respond_with(@attributes)
  end

  def show
    respond_with(@attribute)
  end

  def new
    @attribute = Attribute.new
    respond_with(@attribute)
  end

  def edit
  end

  def get_attribute_categories
    @attribute = Attribute.find(params[:attribute_id])
    @attribute_categories = @attribute.attribute_categories
    render :json => @attribute_categories
  end

  def create
    @attribute = Attribute.new(attribute_params)
    flash[:notice] = "Campo creado." if @attribute.save
    respond_with(@attribute) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
    end
  end

  def update
    flash[:notice] = "Campo editado." if @attribute.update(attribute_params)
    respond_with(@attribute) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
    end
  end

  def destroy
    flash[:notice] = "Campo eliminado." if @attribute.destroy
    respond_with(@attribute) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
    end
  end

  private
    def set_attribute
      @attribute = Attribute.find(params[:id])
    end

    def attribute_params
      params.require(:attribute).permit(:company_id, :name, :description, :datatype, :mandatory)
    end
end
