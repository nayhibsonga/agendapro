class AddCountryToCompany < ActiveRecord::Migration
  def change
    add_reference :companies, :country, index: true
  end
end
