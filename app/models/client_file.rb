class ClientFile < ActiveRecord::Base

	belongs_to :client
	before_destroy :delete_file

	def get_size
		return size
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

    	folder_path = 'companies/' +  self.client.company_id.to_s + '/clients/' + self.client_id.to_s + '/' + self.folder + '/'
    	folder_obj = s3_bucket.object(folder_path)

    	if !folder_obj.exists?
    		s3 = Aws::S3::Client.new
			s3.put_object(bucket: ENV['S3_BUCKET'], key: folder_path)
    	end

	end

end
