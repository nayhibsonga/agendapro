class AddMarketplaceToEconomicSectors < ActiveRecord::Migration
  def change
    add_column :economic_sectors, :marketplace, :boolean, default: false
  end
end
