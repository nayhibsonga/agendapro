class BaseEmailWorker
  require 'rfc822'

  def self.filter_mails(recipients)
    filtered = []
    recipients.each do |mail|
      if mail.downcase.is_email?
        if EmailBlacklist.find_by_email(mail).nil?
          puts "Email ok #{mail}"
          filtered << mail.downcase
        else
          puts "Email Blacklisted: #{mail}"
        end
      else
        puts "Email Bad Format: #{mail}"
      end
    end
    filtered
  end

end
