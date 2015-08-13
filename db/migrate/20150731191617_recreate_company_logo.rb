class RecreateCompanyLogo < ActiveRecord::Migration
  def change
    Company.all.each do |company|
		begin
			company.logo.cache_stored_file!
			company.logo.retrieve_from_cache!(company.logo.cache_name)
			company.logo.recreate_versions!
			company.save!
		rescue => e
			puts  "ERROR: YourModel: #{company.id} -> #{e.to_s}"
		end
	end
  end
end
