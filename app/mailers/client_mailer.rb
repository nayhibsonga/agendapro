class ClientMailer < Base::CustomMailer
  helper ClientsHelper

  def process_campaign(id)
    content = Email::Content.find(id)
    content.to.split(', ').each do |recipient|
      send_campaign(content, recipient.strip.downcase)
    end
  end

  def send_campaign(content, recipient)
    @content = content
    @data = @content.data
    @email = true
    subject = (Rails.env == 'production' ? @content.subject : "#{@content.subject} (#{recipient})")
    headers["X-MC-PreserveRecipients"] = "false"
    mail(
      from: filter_sender("#{@content.company.name.titleize} <no-reply@agendapro.co>"),
      bcc: filter_recipient(recipient),
      subject: subject,
      reply_to: @content.from,
      template_path: Email::Template::TMPL_DIR,
      template_name: "_"+@content.template.name
      )
  end
end
