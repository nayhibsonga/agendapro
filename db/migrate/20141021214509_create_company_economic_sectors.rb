class CreateCompanyEconomicSectors < ActiveRecord::Migration
  def change
    create_table :company_economic_sectors do |t|
      t.references :company, index: true
      t.references :economic_sector, index: true

      t.timestamps
    end
  end
end
