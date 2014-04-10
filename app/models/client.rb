class Client < ActiveRecord::Base
  belongs_to :company

  validates_uniqueness_of :email, :scope => [:first_name, :last_name]

  validates :email, :first_name, :last_name, :presence => true
end
