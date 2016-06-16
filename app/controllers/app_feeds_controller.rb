class AppFeedsController < ApplicationController
  before_action :set_app_feed, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :quick_add
  layout "admin"
  load_and_authorize_resource

  def index
    @app_feeds = AppFeed.where(:company_id => current_user.company_id).order(:created_at)
  end

  def show
  end

  def new
    @app_feed = AppFeed.new
    @app_feed.company_id = current_user.company_id
  end

  def edit
  end

  def create
    @app_feed = AppFeed.new(app_feed_params)
    @app_feed.company_id = current_user.company_id

    respond_to do |format|
      if @app_feed.save
        format.html { redirect_to app_feeds_path, notice: 'Aviso para App creado exitosamente.' }
        format.json { render action: 'show', status: :created, location: @app_feed }
      else
        format.html { render action: 'new' }
        format.json { render json: @app_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @app_feed.update(app_feed_params)
        format.html { redirect_to app_feeds_path, notice: 'Aviso para App actualizado exitosamente.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @app_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @app_feed.destroy
    respond_to do |format|
      format.html { redirect_to app_feeds_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_feed
      @app_feed = AppFeed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_feed_params
      params.require(:app_feed).permit(:title, :company_id, :subtitle, :body, :external_url, :image, :remove_image)
    end
end
