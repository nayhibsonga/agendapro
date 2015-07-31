class RecreateCompanyLogo < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.logo.recreate_versions!
    end
  end
end
