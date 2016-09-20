class AddBooleansToEconomicSectors < ActiveRecord::Migration
  def change
  	add_column :economic_sectors, :show_in_home, :boolean, default: true
  	add_column :economic_sectors, :show_in_company, :boolean, default: true
  end
end
