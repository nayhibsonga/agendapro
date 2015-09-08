class ProviderGroup < ActiveRecord::Base
  belongs_to :company
  belongs_to :location

  has_many :provider_group_auxs
  has_many :service_providers, through: :provider_group_auxs

  validates :location, :provider_group_auxs, presence: true
end
