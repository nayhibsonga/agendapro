class ChangeBirthDateToClients < ActiveRecord::Migration
	
	add_column :clients, :birth_day, :integer
	add_column :clients, :birth_month, :integer
	Client.all.each do |client|
		if !client.birth_date.nil?
			client.birth_month = client.birth_date.month
			client.birth_day = client.birth_date.day
			if client.save
				puts client.id.to_s+" OK"
			else
				puts client.id.to_s+" ERROR"
			end
		end
	end
	remove_column :clients, :birth_date
end
