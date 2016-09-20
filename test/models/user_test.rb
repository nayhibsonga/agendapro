require 'test_helper'

class UserTest < ActiveSupport::TestCase


    def setup

    end


    test "same_email_test" do
        user = User.new(users(:user_1).attributes.to_options)
        user.id = nil
        assert_not user.save, "Saved user with existing email"
    end

    test "gets_registration_mail" do
        new_user = User.new(users[:normal_user].attributes.to_options)
        new_user.id = nil
        new_user.save

    end

    test "gets_past_bookings" do

        books = []
        books << bookings(:booking_1)
        book = bookings(:booking_1)

        client = clients(:client_0)

        user = User.create(:id => 1, :first_name => client.first_name, :last_name => client.last_name, :phone => client.phone, :email => client.email, :password => Devise.bcrypt(User, 'password'))

        book.user_id = user.id
        book.save

        Booking.where(client_id: Client.where(email: user.email)).each do |booking|
            puts "There is one at least"
            booking.update(user_id: user.id)
        end



        #user.get_past_bookings

        #Booking.where(client_id: Client.where(email: user.email)).each do |booking|
        #    booking.update(user_id: user.id)
        #end

        puts "Saved. Waiting for callbacks."
        sleep 2
        puts "Awakes."

        puts user.inspect
        puts client.inspect
        puts book.inspect

        puts "User ID: " + user.id.to_s
        puts "Book1 User ID:" + book.user_id.to_s

        assert_equal 1, user.bookings.count, "Past bookings are not correctly set"

    end


    # test "company_nil_after_delete" do

    #     user = users(:user_2)
    #     company = user.company
    #     company.delete
    #     assert_equal nil, user.company, "Company delete failed"

    # end

end
