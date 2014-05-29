class CorrectEmailToBookings < ActiveRecord::Migration
  def change
  	Booking.all.each do |booking|
		email = booking.email
		atpos = email.index('@');
		dotpos = email.rindex('.');
		if dotpos && atpos
			if (atpos < 1) || (dotpos < atpos+2) || (dotpos+2 >= email.length)
				booking.email = ''
				booking.send_mail = false
				booking.save
			end
		else
			booking.email = ''
			booking.send_mail = false
			booking.save
		end
	end
	Client.all.each do |client|
		email = client.email
		atpos = email.index('@');
		dotpos = email.rindex('.');
		if dotpos && atpos
			if (atpos < 1) || (dotpos < atpos+2) || (dotpos+2 >= email.length)
				client.email = ''
				client.save
			end
		else
			client.email = ''
			client.save
		end
	end
  end
end
