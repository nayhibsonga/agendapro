class AddMarketplaceCategoryToEconomicSectors < ActiveRecord::Migration
  def change
    add_reference :economic_sectors, :marketplace_category, index: true
  end
end
