class SessionsBookingMailer < Base::CustomMailer
  layout "mailers/green"

  #Mail de reserva de servicio con sesiones
  def sessions_booking(bookings, recipient, options = {})
    book = bookings.first
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}",
      horachic: false
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Nueva Reserva en #{@company.name}"
    @url = @company.web_url
    @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")

    # view variables
    @bookings = bookings
    @company_setting = @company.company_setting
    @client = options[:client]
    @name = options[:name]

    mail(
      from: filter_sender(),
      reply_to: filter_sender(book.location.email),
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
