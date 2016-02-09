class FileAttribute < ActiveRecord::Base
	belongs_to :attribute
	belongs_to :client
	belongs_to :client_file

	before_destroy :delete_file

	def delete_file

		self.client_file.destroy

	end

end
