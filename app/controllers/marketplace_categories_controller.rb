class MarketplaceCategoriesController < ApplicationController
  before_action :set_economic_sector, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :verify_is_super_admin
  layout "admin"
  load_and_authorize_resource

  respond_to :html

  def index
    @marketplace_categories = MarketplaceCategory.all
    respond_with(@marketplace_categories)
  end

  def show
    respond_with(@marketplace_category)
  end

  def new
    @marketplace_category = MarketplaceCategory.new
    respond_with(@marketplace_category)
  end

  def edit
  end

  def create
    @marketplace_category = MarketplaceCategory.new(marketplace_category_params)
    @marketplace_category.save
    respond_with(marketplace_categories_path)
  end

  def update
    @marketplace_category.update(marketplace_category_params)
    respond_with(marketplace_categories_path)
  end

  def destroy
    @marketplace_category.destroy
    respond_with(marketplace_categories_path)
  end

  private
    def set_marketplace_category
      @marketplace_category = MarketplaceCategory.find(params[:id])
    end

    def marketplace_category_params
      params.require(:marketplace_category).permit(:name, :show_in_marketplace)
    end
end
