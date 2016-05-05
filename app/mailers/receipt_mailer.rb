class ReceiptMailer < Base::CustomMailer
  layout "mailers/agendapro"

  def online_receipt(receipt, recipient, type)
    # layout variables
    @title = "Comprobante de pago de cuenta AgendaPro"
    @header = "Comprobante de pago."

    # view variables
    @receipt = receipt
    @company = company(@receipt, type)
    @chile = @company.country.name == "Chile"
    @admin = @company.users.where(role_id: Role.find_by_name('Administrador General')).first
    @amount = type == "PayUNotification" ? @receipt.amount : @receipt.value
    card_number = type == "PayUNotification" ? @receipt.cc_number : @receipt.card_number
    @card_number = card_number.present? ? "********#{card_number}" : "NA"
    @auth_code = @receipt.authorization_code.present? ? @receipt.authorization_code : "NA"
    @payment_method = payment_method(receipt, type)

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: recipient,
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  private
    def company(receipt, type)
      company_id = case type
      when "PayUNotification"
        if BillingLog.find_by_trx_id(receipt.reference_sale)
          BillingLog.find_by_trx_id(receipt.reference_sale).company_id
        elsif PlanLog.find_by_trx_id(receipt.reference_sale)
          PlanLog.find_by_trx_id(receipt.reference_sale).company_id
        end
      when "PuntoPagosConfirmation"
        if BillingLog.find_by_trx_id(receipt.trx_id)
          BillingLog.find_by_trx_id(receipt.trx_id).company_id
        elsif PlanLog.find_by_trx_id(receipt.trx_id)
          PlanLog.find_by_trx_id(receipt.trx_id).company_id
        end
      end
      return Company.find(company_id)
    end

    def payment_method(receipt, type)
      if type == "PayUNotification"
        receipt.payment_method_name
      else
        code_to_payment_method(receipt.payment_method)
      end
    end

    def code_to_payment_method(code)

      return_str = "Sin información"

      if code == "03" || code == "3"
        return_str = "WebPay"
      elsif code == "04" || code == "4"
        return_str = "Banco de Chile"
      elsif code == "05" || code == "5"
        return_str = "Banco BCI"
      elsif code == "06" || code == "6"
        return_str = "Banco TBanc"
      elsif code == "07" || code == "7"
        return_str = "BancoEstado"
      elsif code == "16"
        return_str = "Banco BBVA"
      end

      return return_str

    end
end
