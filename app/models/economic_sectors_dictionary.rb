class EconomicSectorsDictionary < ActiveRecord::Base
  belongs_to :economic_sector

  validates :name, :presence => true
end
