class Resource < ActiveRecord::Base
  belongs_to :resource_category
  belongs_to :company

  has_many :service_resources, dependent: :destroy
  has_many :services, :through => :service_resources

  has_many :resource_locations, dependent: :destroy
  has_many :locations, :through => :resource_locations

  accepts_nested_attributes_for :resource_locations, :reject_if => :all_blank, :allow_destroy => true

  validates :resource_category_id, presence: true
  validates_uniqueness_of :name, scope: :company_id
end
