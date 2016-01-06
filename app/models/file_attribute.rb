class FileAttribute < ActiveRecord::Base
	belongs_to :attribute
	belongs_to :client
	belongs_to :client_file
end
