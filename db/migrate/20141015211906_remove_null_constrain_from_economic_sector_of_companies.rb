class RemoveNullConstrainFromEconomicSectorOfCompanies < ActiveRecord::Migration
  def change
  	change_column_null :companies, :economic_sector, false
  end
end
