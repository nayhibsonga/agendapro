class FileAttribute < ActiveRecord::Base
	belongs_to :attribute
	belongs_to :client
	belongs_to :client_file

	before_destroy :delete_file

	def delete_file
		if !self.client_file_id.nil? && !self.client_file.nil?
			self.client_file.destroy
		end
	end

end
