class AddClientToBookings < ActiveRecord::Migration
  def up
    add_reference :bookings, :client, index: true
    Booking.all.order(:updated_at).each do |booking|
      if booking.email == ''
      	if Client.where(email: '', first_name: booking.first_name, last_name: booking.last_name, company_id: booking.service_provider.company_id).count > 0
      		booking.client = Client.where(first_name: booking.first_name, last_name: booking.last_name, company_id: booking.service_provider.company_id).first
      		booking.save
      	else
      		c = Client.create(email: '', first_name: booking.first_name, last_name: booking.last_name, phone: booking.phone, company_id: booking.service_provider.company_id)
      		c.save
      		booking.client = c
      		booking.save
      	end
      else
      	if Client.where(email: booking.email, company_id: booking.service_provider.company_id).count > 0
      		booking.client = Client.where(email: booking.email, company_id: booking.service_provider.company_id).first
      		booking.save
      	else
      		c = Client.create(email: booking.email, first_name: booking.first_name, last_name: booking.last_name, phone: booking.phone, company_id: booking.service_provider.company_id)
      		c.save
      		booking.client = c
      		booking.save
      	end
      end
    end
    remove_column :bookings, :first_name
    remove_column :bookings, :last_name
    remove_column :bookings, :email
    remove_column :bookings, :phone
  end
  def down
    add_column :first_name, :last_name, :email, :phone
    Booking.all.order(updated_at: :desc).each do |booking|
      booking.first_name = booking.client.first_name
      booking.last_name = booking.client.last_name
      booking.email = booking.client.email
      booking.phone = booking.client.phone
    end
    remove_reference :client
  end
end
