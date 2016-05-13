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
    headers["Content-Type"] = "multipart/mixed"
    if @content.attachment_name.present?
      attachments[@content.attachment_name] = { mime_type: @content.attachment_type, content: open(@content.attachment_content).read }
    end
    if content.template == Email::Template.where(name: "plantilla_00").first
      @company = @content.company
      @url = @company.web_url
      @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    end

    headers["X-MSYS-API"] = { "options" => { "open_tracking" => true, "click_tracking" => true }, "metadata" => { "campaign_id" => "#{@content.id}" } }.to_json

    mail(
      from: filter_sender("#{@content.company.name.titleize} <no-reply@#{ENV['EMAIL_SENDING_DOMAIN']}>"),
      bcc: recipient,
      subject: @content.subject,
      reply_to: @content.from,
      template_path: Email::Template::TMPL_DIR,
      template_name: "_"+@content.template.name
    )
    fix_mixed_attachments
  end

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end

    def fix_mixed_attachments
      # do nothing if we have no actual attachments
      return if @_message.parts.select { |p| p.attachment? && !p.inline? }.none?

      mail = Mail.new

      related = Mail::Part.new
      related.content_type = @_message.content_type
      @_message.parts.select { |p| !p.attachment? || p.inline? }.each { |p| related.add_part(p) }
      mail.add_part related

      mail.header       = @_message.header.to_s
      mail.bcc          = @_message.header[:bcc].value # copy bcc manually because it is omitted in header.to_s
      mail.content_type = nil
      @_message.parts.select { |p| p.attachment? && !p.inline? }.each { |p| mail.add_part(p) }

      @_message = mail
      wrap_delivery_behavior!(delivery_method.to_sym)
    end
end
