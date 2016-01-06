class ClientFile < ActiveRecord::Base
	belongs_to :client

	def get_size
		return (self.size.to_f / 1000.0).round(0).to_s + " KB"
	end

	def get_extension
		return self.name[self.name.rindex(".") + 1, self.name.length]
	end

	def is_image

		image_types = ["jpg", "jpeg", "png", "bmp", "gif"]
		
		if image_types.include?(self.get_extension.downcase)
			return true
		else

		return false

	end

end
