module Api
  module V1
  	class UsersController < V1Controller
  	  skip_before_filter :check_auth_token, only: [:login, :create, :oauth]
      skip_before_filter :permitted_params, only: [:oauth]
  	  before_action :check_login_params, only: [:login]
      before_action :parse_registration_params, only: [:create]

      def create
        @user = User.new(user_params)
        @user.role = Role.find_by_name("Usuario Registrado")
        @user.request_mobile_token
        render :json => @user.errors.full_messages, :status=>422 unless @user.save
      end

      def edit
        @user = @mobile_user
        render json: { error: @user.errors.full_messages }, status: 422 if !@user.update(user_params.except(:email))
      end

      def login
        @user = User.find_by_email(params[:email])
        if @user && @user.valid_password?(params[:password])
          if @user.mobile_token.blank?
            @user.request_mobile_token
            render json: { error: @user.errors.full_messages }, status: 422 if !@user.save
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



        @activeBookings = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where(:client_id => @client_ids, :status_id => Status.find_by(:name => ['Reservado', 'Pagado', 'Confirmado'])).where("start > ?", DateTime.now - eval(ENV["TIME_ZONE_OFFSET"])).order(:start).group_by{ |i| i.start.to_date }
        @lastBookings = Booking.where('is_session = false or (is_session = true and is_session_booked = true)').where("start <= ?", DateTime.now - eval(ENV["TIME_ZONE_OFFSET"])).where(:client_id => @client_ids).order(updated_at: :desc).limit(10).group_by{ |i| i.start.to_date }
      end

      def favorites
        @locations = @mobile_user.favorite_locations
      end

      def mobile_user
      end

      def oauth
        if params[:device] == 'facebook'
          fb_user = FbGraph::User.me(params[:access_token]).fetch(fields: [:email, :first_name, :last_name, :id])
          if fb_user.raw_attributes[:email].blank?
            render json: { error: 'Lo sentimos, tu cuenta de Facebook no tiene un correo electrónico asociado, por lo que no podremos registrarte' }, status: 403
          else
            if User.find_by_email(fb_user.raw_attributes[:email])
              @user = User.find_by_email(fb_user.raw_attributes[:email])
              @user.first_name = fb_user.raw_attributes[:first_name]
              @user.last_name = fb_user.raw_attributes[:last_name]
              @user.uid = fb_user.raw_attributes[:id]
              @user.role = Role.find_by_name('Usuario Registrado')
              @user.provider = 'facebook'
              @user.request_mobile_token
              render :json => @user.errors.full_messages, :status=>422 unless @user.save
            else
              @user = User.new(email: fb_user.raw_attributes[:email], first_name: fb_user.raw_attributes[:first_name], last_name: fb_user.raw_attributes[:last_name], role_id: Role.find_by_name('Usuario Registrado').id, uid: fb_user.raw_attributes[:id], provider: 'facebook', password: SecureRandom.base64(16))
              @user.request_mobile_token
              render :json => @user.errors.full_messages, :status=>422 unless @user.save
            end
          end
        elsif params[:device] == 'google_oauth2'

        else
          render json: { error: 'Invalid Device' }, status: 403
        end
      end

      def searches
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

      def parse_registration_params
        params[:user] = {}
        params[:user][:email] =  params[:email] unless params[:email].blank?
        params[:user][:password] = params[:password] unless params[:password].blank?
        params[:user][:phone] = params[:phone] unless params[:phone].blank?

        nameArray = []
        nameArray = params[:name].split(' ') unless params[:name].blank?
        if nameArray.length == 0

        elsif nameArray.length == 1
          params[:user][:first_name] = nameArray[0] unless nameArray[0].blank?
        elsif nameArray.length == 2
          params[:user][:first_name] = nameArray[0] unless nameArray[0].blank?
          params[:user][:last_name] = nameArray[1] unless nameArray[1].blank?
        elsif nameArray.length == 3
          params[:user][:first_name] = nameArray[0] unless nameArray[0].blank?
          params[:user][:last_name] = nameArray[1] + ' ' + nameArray[2]
        else 
          params[:user][:first_name] = nameArray[0] + ' ' + nameArray[1]
          last_name = ''
          (2..nameArray.length - 1).each do |i|
            last_name += nameArray[i]+' '
          end
          strLen = last_name.length
          last_name = last_name[0..strLen-1]
          params[:user][:last_name] = last_name unless last_name.blank?
        end
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password, :phone)
      end
  	end
  end
end