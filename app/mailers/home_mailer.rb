class HomeMailer < ActionMailer::Base
  default from: "agendapro@agendapro.cl"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.home_mailer.contact.subject
  #
  def contact_mail (contact_info)
    @firstName = contact_info['firstName']
    @lastName = contact_info['lastName']
    complete_name = @lastName + ', ' + @firstName
    email_with_name = "#{complete_name} <#{contact_info['email']}>"
    subject = contact_info['subject']
    @message = contact_info['message']

    attachments.inline['logo.png'] = File.read('app/assets/images/home/Logo.png')

    mail(to: email_with_name, subject: subject)
  end
end
