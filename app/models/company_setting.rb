class CompanySetting < ActiveRecord::Base
	belongs_to :company

	#validates :email, :sms, :presence => true

	def self.daily_mails
		all.each do |setting|
			setting.update_attributes :sent_mails => 0
		end
	end
end
