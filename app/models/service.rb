class Service < ActiveRecord::Base
	belongs_to :company
	belongs_to :tag

	has_many :staffs, :through => :service_staffs
end
