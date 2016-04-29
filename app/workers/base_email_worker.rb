class BaseEmailWorker
  def self.filter_mails(recipients)
    filtered = []
    recipients.each do |mail|
      if mail =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
        if EmailBlacklist.find_by_email(mail).nil?
          puts "Email ok #{mail}"
          filtered << mail
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
