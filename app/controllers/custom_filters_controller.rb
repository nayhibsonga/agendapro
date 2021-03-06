class CustomFiltersController < ApplicationController
  before_action :set_custom_filter, only: [:show, :edit, :update, :destroy, :edit_filter_form]

  respond_to :html, :json

  def index
    @custom_filters = CustomFilter.all
    respond_with(@custom_filters)
  end

  def show
    respond_with(@custom_filter)
  end

  def new
    @custom_filter = CustomFilter.new
    respond_with(@custom_filter)
  end

  def edit
  end

  def create
    @custom_filter = CustomFilter.new(custom_filter_params)

    respond_with(@custom_filter) do |format|
      if @custom_filter.save && @custom_filter.create_filters(params)
        flash[:success] = "Filtro creado."
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
      else
        flash[:error] = "Filtro no pudo ser creado."
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
      end
    end
  end

  def update
    @custom_filter.update(custom_filter_params)

    respond_with(@custom_filter) do |format|
      if @custom_filter.update(custom_filter_params) && @custom_filter.create_filters(params)
        flash[:success] = "Filtro actualizado."
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
      else
        flash[:error] = "Filtro no pudo ser actualizado."
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
      end
    end
  end

  def destroy
    respond_with(@custom_filter) do |format|
      if @custom_filter.destroy
        flash[:success] = "Filtro eliminado."
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
      else
        flash[:error] = "Filtro no pudo ser eliminado."
        format.html { redirect_to edit_company_setting_path(current_user.company.company_setting, anchor: 'clients') }
      end
    end
  end

  def new_filter_form
    @custom_filter = CustomFilter.new
    respond_to do |format|
      format.html { render :partial => 'form' }
      format.json { render json: @custom_filter }
    end
  end

  def edit_filter_form
    respond_to do |format|
      format.html { render :partial => 'edit_form' }
      format.json { render json: @custom_filter }
    end
  end

  private
    def set_custom_filter
      @custom_filter = CustomFilter.find(params[:id])
    end

    def custom_filter_params
      params.require(:custom_filter).permit(:company_id, :name)
    end
end
