class RecreateCompanyLogo < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      if (!company.logo.url.include? 'logo_vacio') && File.exist?('public' + company.logo.url)
        company.logo.recreate_versions!
      end
    end
  end
end
