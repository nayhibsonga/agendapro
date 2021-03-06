class CompanyCountry < ActiveRecord::Base
  belongs_to :company
  belongs_to :country

  validates :company, :web_address, :country, :presence => true

  validates_uniqueness_of :web_address, scope: :country_id

  attr_accessor :active

  before_destroy :validate_locations

  def validate_locations
  	if Location.actives.where(country_id: self.country, company_id: self.company_id).count > 0
		errors.add(:base, "No puede eliminar un país con locales asociados.")
		false
	else
		true
  	end
  end
end
