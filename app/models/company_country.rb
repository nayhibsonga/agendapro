class CompanyCountry < ActiveRecord::Base
  belongs_to :company
  belongs_to :country

  validates :company, :web_address, :country, :presence => true

  validates_uniqueness_of :web_address, scope: :country_id

  attr_accessor :active
end
