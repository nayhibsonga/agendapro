require 'rails_helper'

describe User do

	it "should not create existing email" do

		@role = FactoryGirl.create(:role)
		@user = build(:user, role: @role)
		@new_user = User.new(@user.attributes.to_options)
		@new_user.id = nil
		@new_user.should be_valid

	end

	it "should fire callbacks" do

		#@books = []
		#@client = Client.all.first
        #@books << Booking.find_by_client_id(@client.id)
        #@book = @books.first        
        #@role = Role.find_by_name('Usuario Registrado')

        @client = FactoryGirl.create(:client)

        @user = FactoryGirl.build(:user, first_name: @client.first_name, last_name: @client.last_name, phone: @client.phone, email: @client.email)
        	#, role_id: @role.id)

        @user.should_receive(:get_past_bookings)
        @user.should_receive(:send_welcome_mail)

        @user.save


	end

end