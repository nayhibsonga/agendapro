class DefaultCompanyCountries < ActiveRecord::Migration
  Company.all.each do |company|
  	cc = CompanyCountry.new(company_id: company.id, country_id: company.country_id, web_address: company.web_address)
  	if cc.save then puts "OK "+ company.id.to_s else puts "ERROR " + company.id.to_s + " " + company.errors.full_messages.inspect end
  end
end
