module Api
  module V1
  	class UsersController < V1Controller
  	  skip_before_filter :check_auth_token, only: [:login, :create]
  	  before_action :check_login_params, only: [:login]

      def create
        @user = User.new(user_params)
        @user.role = Role.find_by_name("Usuario Registrado")
        @user.request_mobile_token
        render :json => @user.errors.full_messages, :status=>422 unless @user.save
      end

      def login
        @user = User.find_by_email(params[:email])
        if @user.valid_password?(params[:password])
          if @user.mobile_token.blank?
            @user.request_mobile_token
            render json: { error: 'Invalid User. User not saved.' }, status: 500 if !@user.save
          end
        else
          render json: { error: 'Invalid User' }, status: 403
        end
      end

      def bookings
        @client_ids = Client.where(:email => @mobile_user.email).pluck(:id)
        @preSessionBookings = SessionBooking.where(:client_id => @client_ids)

        @preSessionBookings.each do |sb|
          if sb.user_id.nil?
            sb.user_id = current_user.id
            sb.save
          end
          if sb.bookings.count == 0
            sb.delete
          end
        end

        @preSessionBookings = SessionBooking.where(:client_id => @client_ids)

        @sessionBookings = []

        @preSessionBookings.each do |session_booking|

          include_sb = false

          if session_booking.sessions_taken < session_booking.sessions_amount
            include_sb = true
          else
            session_booking.bookings.each do |booking|
              if booking.start > DateTime.now
                include_sb = true
              end
            end
          end

          if include_sb
            @sessionBookings << session_booking
          end

        end



        @activeBookings = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(:client_id => @client_ids, :status_id => Status.find_by(:name => ['Reservado', 'Pagado', 'Confirmado'])).where("start > ?", DateTime.now).order(:start).group_by{ |i| i.start.to_date }
        @lastBookings = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(:client_id => @client_ids).order(updated_at: :desc).limit(10).group_by{ |i| i.start.to_date }
      end

      def favorites
        @locations = @mobile_user.favorite_locations
      end

      def mobile_user
      end

      private
      
  	  def check_login_params
  	  	if !params[:email].present? || !params[:password].present?
          render json: { error: 'Invalid User. Param(s) missing.' }, status: 500
  	  	end
  	  end

      def check_registration_params
        if !params[:email].present? || !params[:password].present? || !params[:name].present?
          render json: { error: 'Invalid User. Param(s) missing.' }, status: 500
        end
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password)
      end
  	end
  end
end