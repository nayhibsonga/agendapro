class StaffTime < ActiveRecord::Base
	belongs_to :day
	belongs_to :staff

	validates :open, :close, :presence => true
end
