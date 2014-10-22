class CompanyEconomicSector < ActiveRecord::Base
  belongs_to :company
  belongs_to :economic_sector
end
