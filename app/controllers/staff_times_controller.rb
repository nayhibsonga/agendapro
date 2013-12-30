class StaffTimesController < ApplicationController
  before_action :set_staff_time, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  layout "admin"

  # GET /staff_times
  # GET /staff_times.json
  def index
    @staff_times = StaffTime.all
  end

  # GET /staff_times/1
  # GET /staff_times/1.json
  def show
  end

  # GET /staff_times/new
  def new
    @staff_time = StaffTime.new
  end

  # GET /staff_times/1/edit
  def edit
  end

  # POST /staff_times
  # POST /staff_times.json
  def create
    @staff_time = StaffTime.new(staff_time_params)

    respond_to do |format|
      if @staff_time.save
        format.html { redirect_to @staff_time, notice: 'Staff time was successfully created.' }
        format.json { render action: 'show', status: :created, location: @staff_time }
      else
        format.html { render action: 'new' }
        format.json { render json: @staff_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staff_times/1
  # PATCH/PUT /staff_times/1.json
  def update
    respond_to do |format|
      if @staff_time.update(staff_time_params)
        format.html { redirect_to @staff_time, notice: 'Staff time was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @staff_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_times/1
  # DELETE /staff_times/1.json
  def destroy
    @staff_time.destroy
    respond_to do |format|
      format.html { redirect_to staff_times_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff_time
      @staff_time = StaffTime.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def staff_time_params
      params.require(:staff_time).permit(:open, :close, :staff_id, :day_id)
    end
end
