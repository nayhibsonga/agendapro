Company.all.each do |c|

	if c.company_setting.nil?

		cs = CompanySetting.new
		cs.company_id = c.id
		cs.save

	end

	if c.company_setting.online_cancelation_policy.nil?

		ocp = OnlineCancelationPolicy.new
		ocp.company_setting_id = c.company_setting.id
		ocp.save

	end

	c.save
	puts "Online policy created."

end