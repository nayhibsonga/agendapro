class CustomFiltersController < ApplicationController
  before_action :set_custom_filter, only: [:show, :edit, :update, :destroy]

  respond_to :html

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
    @custom_filter.save
    respond_with(@custom_filter)
  end

  def update
    @custom_filter.update(custom_filter_params)
    respond_with(@custom_filter)
  end

  def destroy
    @custom_filter.destroy
    respond_with(@custom_filter)
  end

  def new_filter_form
    @custom_filter = CustomFilter.new
    respond_to do |format|
      format.html { render :partial => 'form' }
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
