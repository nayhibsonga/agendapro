class DefaultCountryToCompany < ActiveRecord::Migration
  def change
	  Company.all.each do |company|
	  	company.country = Country.find_by_name("Chile")
	  	if company.save
	  		puts "OK company id: " + company.id.to_s
	  	else
	  		puts "OK company id: " + company.id.to_s + " " + company.errors.full_messages.inspect
		end
	  end
  end
end
