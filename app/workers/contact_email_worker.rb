class ContactEmailWorker

  def self.perform(contact_info, mobile)
    contact = {
      client: {
        email: contact_info[:email],
        name: "#{contact_info[:firstName]} #{contact_info[:lastName]}"
      },
      content: {
        subject: contact_info[:subject],
        message: contact_info[:message]
      }
    }
    if mobile
      contact[:client][:phone] = contact_info[:phone]
    end
    HomeMailer.delay.contact(contact, mobile)
  end

end
