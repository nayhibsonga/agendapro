class RecreateCompanyLogo < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      if !company.logo.url.include? 'logo_vacio' && company.logo.url.file.exists?
        company.logo.recreate_versions!
      end
    end
  end
end
