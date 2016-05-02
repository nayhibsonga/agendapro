class ClientMailer < Base::CustomMailer
  helper ClientsHelper

  def process_campaign(id)
    content = Email::Content.find(id)
    content.to.split(', ').each do |recipient|
      send_campaign(content, recipient.strip.downcase)
    end
  end

  def send_campaign(content, recipient)
    # puts content.inspect
    @content = content
    @data = @content.data
    @email = true
    headers["X-MC-PreserveRecipients"] = "false"
    if @content.attachment_name.present?
      attachments[@content.attachment_name] = open(@content.attachment_content).read
    end
    if content.template == Email::Template.where(name: "plantilla_00").first
      @company = @content.company
      @url = @company.web_url
      @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    end
    mail(
      from: filter_sender("#{@content.company.name.titleize} <no-reply@agendapro.co>"),
      bcc: recipient,
      subject: @content.subject,
      reply_to: @content.from,
      template_path: Email::Template::TMPL_DIR,
      template_name: "_"+@content.template.name
    )
  end

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end
end
