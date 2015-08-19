class AddDomainToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :domain, :string, default: ""
  end
end
