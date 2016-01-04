class ClientFile < ActiveRecord::Base
	belongs_to :client

	def get_size

		return (size.to_f / 1000.0).round(0).to_s + " KB"

	end

end
