class CorrectEmailToBookings < ActiveRecord::Migration
  def change
  	Booking.all.each do |booking|
  		booking.service_provider.bookings.each do |booking2|
  			if booking != booking2 && booking.start == booking2.start && booking.end == booking2.end && booking.location == booking2.location && booking.service == booking2.service && booking.status == booking2.status
  				booking2.destroy
  			end
  		end
		email = booking.email
		atpos = email.index('@');
		dotpos = email.rindex('.');
		if dotpos && atpos
			if (atpos < 1) || (dotpos < atpos+2) || (dotpos+2 >= email.length)
				booking.email = ''
				booking.send_mail = false
				f = booking.save
				puts f.to_s + ' ' + booking.id.to_s + ' booking corregido'
			end
		else
			booking.email = ''
			booking.send_mail = false
			f = booking.save
			puts f.to_s + ' ' + booking.id.to_s + ' booking corregido'
		end
	end
	Client.all.each do |client|
		email = client.email
		atpos = email.index('@');
		dotpos = email.rindex('.');
		if dotpos && atpos
			if (atpos < 1) || (dotpos < atpos+2) || (dotpos+2 >= email.length)
				client.email = ''
				f = client.save
				puts f.to_s + ' ' + client.id.to_s + ' client corregido'
			end
		else
			client.email = ''
			f = client.save
			puts f.to_s + ' ' + client.id.to_s + ' client corregido'
		end
	end
  end
end
