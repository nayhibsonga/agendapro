class ProviderGroupsController < ApplicationController
  before_action :set_provider_group, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @provider_groups = ProviderGroup.where(company_id: current_user.company_id).order(:location_id, :order)
    respond_with(@provider_groups)
  end

  def show
    respond_with(@provider_group)
  end

  def new
    @provider_group = ProviderGroup.new
    respond_with(@provider_group)
  end

  def edit
  end

  def create
    @provider_group = ProviderGroup.new(provider_group_params)
    @provider_group.company_id = current_user.company_id
    @provider_group.save
    respond_with(@provider_group)
  end

  def update
    @provider_group.update(provider_group_params)
    respond_with(@provider_group)
  end

  def destroy
    @provider_group.destroy
    respond_with(@provider_group)
  end

  def change_groups_order
    array_result = Array.new
    params[:groups_order].each do |pos, group_hash|
      group = ProviderGroup.find(group_hash[:provider_group])
      if group.update(:order => group_hash[:order])
        array_result.push({
          provider_group: group.name,
          status: 'Ok'
        })
      else
        array_result.push({
          provider_group: group.name,
          status: 'Error',
          errors: group.errors
        })
      end
    end
    render :json => array_result
  end

  private
    def set_provider_group
      @provider_group = ProviderGroup.find(params[:id])
    end

    def provider_group_params
      params.require(:provider_group).permit(:company_id, :name, :order, :location_id, service_provider_ids: [])
    end
end
