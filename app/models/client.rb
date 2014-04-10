class Client < ActiveRecord::Base
  belongs_to :company

  validates_uniqueness_of :email, :scope => :company_id

  validates :email, :first_name, :last_name, :presence => true
end
