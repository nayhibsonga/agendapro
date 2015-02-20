Company.where(:active => true).each do |c|

	c.company_setting.allows_online_payment = false
	c.company_setting.account_number = ""
	c.company_setting.company_rut = ""
	c.company_setting.account_name = ""
	c.company_setting.account_type = 3
	c.company_setting.bank_id = Bank.first.id
	c.company_setting.save

	puts "Company settings saved."

	c.locations.where(:active => true).each do |l|
		l.service_providers.each do |sp|
			sp.services.each do |s|
				s.online_payable = false
				s.has_discount = false
				s.discount = 0
				s.save
				puts "Service saved."
			end
		end
	end

	c.save

end