class CompanySetting < ActiveRecord::Base
	belongs_to :company

	validates :email, :sms, :presence => true
end
