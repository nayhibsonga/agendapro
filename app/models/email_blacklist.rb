class EmailBlacklist < ActiveRecord::Base

	def self.load_emails(file_path)
		spreadsheet = Roo::Excelx.new(file_path, file_warning: :ignore)
		if !spreadsheet.nil?
      header = spreadsheet.row(1)
      logger.debug "Header: " + header.inspect

      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        EmailBlacklist.create(email: row["email"], sender: row["sender"], status: row["status"])
      end			

		end
	end

end
