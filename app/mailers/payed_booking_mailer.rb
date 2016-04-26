class PayedBookingMailer < Base::CustomMailer
  layout "mailers/green"

  def payment_booking (payed_booking, recipient, options = {})
    # defaults
    options = {
      client: true
    }.merge(options)

    @company = payed_booking.bookings.first.location.company

    # layout variables
    @title = "Comprobante de pago en Agendapro"
    @url = @company.web_url
    attacht_logo("public#{@company.logo.email.url}") unless @company.logo.email.url.include?("logo_vacio")

    # view variables
    @client_present = options[:client]
    @client = "#{payed_booking.bookings.first.client.first_name} #{payed_booking.bookings.first.client.last_name}"
    @punto_pagos = payed_booking.punto_pagos_confirmation
    @auth_code = @punto_pagos.authorization_code.present? ? @punto_pagos.authorization_code : "NA"
    @card_number = @punto_pagos.card_number.present? ? @punto_pagos.card_number : "NA"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: recipient,
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def cancel_payment_booking (payed_booking, recipient, options = {})
    # defaults
    options = {
      client: true,
      company: false,
      agendapro: false
    }.merge(options)

    @company = payed_booking.bookings.first.location.company

    # layout variables
    @title = "Cancelación de pago en Agendapro"
    @url = @company.web_url
    attacht_logo("public#{@company.logo.email.url}") unless @company.logo.email.url.include?("logo_vacio")

    # view variables
    @client_present = options[:client]
    @client = payed_booking.bookings.first.client
    @punto_pagos = payed_booking.punto_pagos_confirmation
    @auth_code = @punto_pagos.authorization_code.present? ? @punto_pagos.authorization_code : "NA"
    @card_number = @punto_pagos.card_number.present? ? @punto_pagos.card_number : "NA"
    @company_present = options[:company]
    @agendapro = options[:agendapro]

    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: recipient,
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end
end
