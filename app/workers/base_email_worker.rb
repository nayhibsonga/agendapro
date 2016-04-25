class BaseEmailWorker
  def self.filter_mails(recipients)
    filtered = []
    recipients.each do |mail|
      filtered << mail if mail =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    end
    filtered
  end

end
