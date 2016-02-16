class AttributeGroupsController < ApplicationController
  before_action :set_attribute_group, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"
  load_and_authorize_resource

  respond_to :html, :json

  def index
    @attribute_groups = AttributeGroup.all
    respond_with(@attribute_groups)
  end

  def show
    respond_with(@attribute_group)
  end

  def new
    @attribute_group = AttributeGroup.new
    respond_with(@attribute_group)
  end

  def edit
  end

  def create
    @attribute_group = AttributeGroup.new(attribute_group_params)
    @attribute_group.save
    flash[:notice] = "Campo creado." if @attribute_group.save
    respond_with(@attribute_group) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
    end
  end

  def update
    flash[:notice] = "Campo editado." if @attribute_group.update(attribute_group_params)
    respond_with(@attribute_group) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
    end
  end

  def destroy
    flash[:notice] = "Campo eliminado." if @attribute_group.destroy
    respond_with(@attribute_group) do |format|
      format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
    end
  end

  private
    def set_attribute_group
      @attribute_group = AttributeGroup.find(params[:id])
    end

    def attribute_group_params
      params.require(:attribute_group).permit(:company_id, :name, :order)
    end
end
