class ProviderGroupsController < ApplicationController
  before_action :set_provider_group, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @provider_groups = ProviderGroup.all
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

  private
    def set_provider_group
      @provider_group = ProviderGroup.find(params[:id])
    end

    def provider_group_params
      params.require(:provider_group).permit(:company_id, :name, :order)
    end
end
