Company.where(:active => true).each do |c|

	c.company_setting.allows_online_payment = true
	c.company_setting.account_number = "000-111-222"
	c.company_setting.company_rut = "11.111.111-1"
	c.company_setting.account_name = "Nombre titular"
	c.company_setting.account_type = 3
	c.company_setting.bank_id = Bank.first.id
	c.company_setting.save

	puts "Company settings saved."

	c.locations.where(:active => true).each do |l|
		l.service_providers.each do |sp|
			sp.services.each do |s|
				s.online_payable = true
				s.has_discount = true
				s.discount = 10
				s.save
				puts "Service saved."
			end
		end
	end

	c.save

end