class HomeMailer < Base::CustomMailer
  layout "mailers/green"

  def contact (contact_info, mobile)
    Rails.logger.debug "mobile: #{mobile}"
    @content = contact_info
    unless mobile
      @greeting = "Gracias por contactarnos, hemos recibido tu email y pronto nos pondremos en contacto contigo."
      recipient = 'contacto@agendapro.cl, #{@content[:client][:name].titleize} <#{@content[:client][:email]}>'
    else
      @greeting = "#{@content[:client][:name]} intento crear una compañia desde el celular."
      recipient = 'contacto@agendapro.cl, '
    end
    subject = "#{@content[:content][:subject]}"

    headers["X-MC-PreserveRecipients"] = "false"
    mail(
      from: filter_sender("#{@content[:client][:name].titleize} <#{@content[:client][:email]}>"),
      to: filter_recipient(recipient),
      subject: subject,
      template_path: "mailers"
      )
  end

  # def mobile_contact (contact_info)
  #   @content = contact_info
  #   @greeting = "#{@content[:client][:name]} intento crear una compañia desde el celular."
  #   recipient = 'contacto@agendapro.cl'
  #   subject = "#{@content[:content][:subject]}"

  #   headers["X-MC-PreserveRecipients"] = "false"
  #   mail(
  #     from: filter_sender("#{@content[:client][:name].titleize} <#{@content[:client][:email]}>"),
  #     to: filter_recipient(recipient),
  #     subject: subject,
  #     template_path: "mailers"
  #     )
  # end
end
