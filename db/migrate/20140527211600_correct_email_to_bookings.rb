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
				puts booking.id.to_s + ' booking corregido'
			end
		else
			booking.email = ''
			booking.send_mail = false
			booking.save
			puts booking.id.to_s + ' booking corregido'
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
				puts client.id.to_s + ' client corregido'
			end
		else
			client.email = ''
			client.save
			puts client.id.to_s + ' client corregido'
		end
	end
  end
end
