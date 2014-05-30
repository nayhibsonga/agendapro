class CorrectEmailToBookings < ActiveRecord::Migration
  def change
  	Booking.where(id: [615, 1562, 1835, 2015, 2060, 2259, 2356, 2434, 2482]).delete_all
  	cancelled_id = Status.find_by(name: 'Cancelado').id
  	Booking.all.order(:id).each do |booking|
  		booking.service_provider.bookings.where(start: booking.start, end: booking.end).each do |booking2|
			if booking != booking2 && booking2.status.id != cancelled_id && booking.status.id != cancelled_id
				puts booking2.id.to_s + ' eliminado duplicado de ' + booking.id.to_s
  				booking2.delete
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
	Client.all.order(:id).each do |client|
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
