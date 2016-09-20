class AddMobilePreviewToEconomicSector < ActiveRecord::Migration
  def change
    add_column :economic_sectors, :mobile_preview, :string, default: ""
  end
end
