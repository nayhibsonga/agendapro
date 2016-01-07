class ClientFile < ActiveRecord::Base

	belongs_to :client
	before_destroy :delete_file

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
		end

		return false

	end

	def delete_file

		s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
    	obj = s3_bucket.object(self.full_path)
    	obj.delete

	end

end
