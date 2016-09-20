class ResourceCategory < ActiveRecord::Base
  has_many :resources
  belongs_to :company

  validates_uniqueness_of :name, scope: :company_id
end
