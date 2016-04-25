class BillingWireTransferMailer < Base::CustomMailer
  layout "mailers/agendapro"

  #Send mail to Nico (or other) warning about a new billing_wire_transfer
  def transfer (transfer, recipient)
    # layout variables
    @title = "Nueva transferencia de pago de cuenta"
    @header = "Nueva transferencia de pago de cuenta."

    # view variables
    @transfer = transfer
    @company = @transfer.company
    @admin = @company.users.where(role_id: Role.find_by_name('Administrador General')).first

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def receipt_transfer (transfer, recipient)
    # layout variables
    @title = "Comprobante de pago de cuenta AgendaPro"
    @header = "Comprobante de pago."

    # view variables
    @transfer = transfer
    @company = @transfer.company
    @admin = @company.users.where(role_id: Role.find_by_name('Administrador General')).first

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end
end
