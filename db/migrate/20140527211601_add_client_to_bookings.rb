class AddClientToBookings < ActiveRecord::Migration
  add_reference :bookings, :client, index: true
  Booking.all.each do |booking|
    if booking.email == ''
    	if Client.where(email: '', first_name: booking.first_name, last_name: booking.last_name, company_id: booking.service_provider.company_id).count > 0
    		booking.client = Client.where(email: '', first_name: booking.first_name, last_name: booking.last_name, company_id: booking.service_provider.company_id).first
    		booking.save
        puts booking.id.to_s + ' encuentra cliente vacio ' + booking.client.id.to_s
    	else
    		c = Client.create(email: '', first_name: booking.first_name, last_name: booking.last_name, phone: booking.phone, company_id: booking.service_provider.company_id)
    		c.save
    		booking.client = c
    		booking.save
        puts booking.id.to_s + ' crea cliente vacio ' + booking.client.id.to_s
    	end
    else
    	if Client.where(email: booking.email, company_id: booking.service_provider.company_id).count > 0
    		booking.client = Client.where(email: booking.email, company_id: booking.service_provider.company_id).first
    		booking.save
        puts booking.id.to_s + ' encuentra cliente lleno ' + booking.client.id.to_s
    	else
    		c = Client.create(email: booking.email, first_name: booking.first_name, last_name: booking.last_name, phone: booking.phone, company_id: booking.service_provider.company_id)
    		c.save
    		booking.client = c
    		booking.save
        puts booking.id.to_s + ' crea cliente lleno ' + booking.client.id.to_s
    	end
    end
  end
  remove_column :bookings, :first_name
  remove_column :bookings, :last_name
  remove_column :bookings, :email
  remove_column :bookings, :phone
end
