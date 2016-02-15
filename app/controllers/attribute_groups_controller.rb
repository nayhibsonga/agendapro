class AttributeGroupsController < ApplicationController
  before_action :set_attribute_group, only: [:show, :edit, :update, :destroy]

  respond_to :html

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
    respond_with(@attribute_group)
  end

  def update
    @attribute_group.update(attribute_group_params)
    respond_with(@attribute_group)
  end

  def destroy
    @attribute_group.destroy
    respond_with(@attribute_group)
  end

  private
    def set_attribute_group
      @attribute_group = AttributeGroup.find(params[:id])
    end

    def attribute_group_params
      params.require(:attribute_group).permit(:company_id, :name, :order)
    end
end
