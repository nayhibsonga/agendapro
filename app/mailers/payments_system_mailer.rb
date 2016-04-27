class PaymentsSystemMailer < Base::CustomMailer
  def receipts (payment, recipient)
    @company = payment.location.company

    # layout variables
    @title = "Comprobantes de pago"
    @url = @company.web_url

    # view variables
    @payment = payment

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: recipient,
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

end
