class DowngradeLog < ActiveRecord::Base
	belongs_to :company
	belongs_to :plan
end
