class NotificationMailer < Base::CustomMailer
  layout "mailers/green"

  def summary (recipient, today_bookings, summary_bookings, name)
    @company = get_company(today_bookings, summary_bookings)

    # layout variables
    @title = "Resumen de Reservas"
    @url = @company.web_url
    @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")

    # view variables
    @today = today_bookings
    @summary = summary_bookings
    @name = name

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  private
    def attacht_logo (url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end

    def get_company (today, summary)
      (today.try(:first) || summary.try(:first)).location.company
    end
end
