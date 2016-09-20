class RemoveEconomicSectorFromCompany < ActiveRecord::Migration
  def change
  	Company.where("companies.economic_sector_id IS NOT NULL").each do |company|
  		if EconomicSector.where(id: company.economic_sector_id).count > 0
  			company.economic_sectors = EconomicSector.where(id: company.economic_sector_id)
  			company.save
  		end
  	end
  	remove_reference :companies, :economic_sector, index: true
  end
end
