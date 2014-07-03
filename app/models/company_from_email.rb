class CompanyFromEmail < ActiveRecord::Base
  belongs_to :company

  validates :email, :presence => true
end
