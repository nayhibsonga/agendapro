class ReceiptMailer < Base::CustomMailer
  layout "mailers/agendapro"

  def online_receipt(receipt, recipient, type)
    # layout variables
    @title = "Comprobante de pago de cuenta AgendaPro"
    @header = "Comprobante de pago."

    # view variables
    @receipt = receipt
    @company = self.company(@receipt, type)
    @chile = @company.country.name == "Chile"
    @admin = @company.users.where(role_id: Role.find_by_name('Administrador General')).first
    @amount = @receipt.try(:amount) ? @receipt.amount : @receipt.value
    card_number = @receipt.try(:cc_number) ? @receipt.cc_number : @receipt.card_number
    @card_number = card_number.present? ? "********#{card_number}" : "NA"
    @auth_code = @receipt.authorization_code.present? ? @receipt.auth_code : "NA"
    @payment_method = self.payment_method(receipt, type)

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  #################### Legacy ####################
  def online_receipt_email(company_id, punto_pagos_confirmation_id)
    current_date = DateTime.now
    day_number = Time.now.day
    month_days = Time.now.days_in_month

    message = {
      :global_merge_vars => [
        {
          :name => 'CURRENT_YEAR',
          :content => current_date.year
        },
        {
          :name => 'CURRENT_MONTH',
          :content => (l current_date, :format => '%B').capitalize
        },
        {
          :name => 'ADMIN_NAME',
          :content => admin.full_name
        },
        {
          :name => 'EMAIL',
          :content => admin.email
        },
        {
          :name => 'AMOUNT',
          :content => ActionController::Base.helpers.number_to_currency(amount, locale: company.country.locale.to_sym)
        },
        {
          :name => 'ORDER',
          :content => punto_pagos_confirmation.operation_number
        },
        {
          :name => 'DATE',
          :content => punto_pagos_confirmation.created_at.strftime('%d/%m/%Y %R')
        }
      ]
    }
  end

  def pay_u_online_receipt_email(company_id, pay_u_notification_id)
    current_date = DateTime.now
    day_number = Time.now.day
    month_days = Time.now.days_in_month

    message = {
      :global_merge_vars => [
        {
          :name => 'CURRENT_YEAR',
          :content => current_date.year
        },
        {
          :name => 'CURRENT_MONTH',
          :content => (l current_date, :format => '%B').capitalize
        },
        {
          :name => 'ADMIN_NAME',
          :content => admin.full_name
        },
        {
          :name => 'EMAIL',
          :content => admin.email
        },
        {
          :name => 'AMOUNT',
          :content => ActionController::Base.helpers.number_to_currency(amount, locale: company.country.locale.to_sym)
        },
        {
          :name => 'DATE',
          :content => pay_u_notification.created_at.strftime('%d/%m/%Y %R')
        }
      ]
    }
  end

  private
    def self.company(receipt, type)
      company_id = case type
      when "PayUNotification"
        if BillingLog.find_by_trx_id(receipt.reference_sale)
          billing_log = BillingLog.find_by_trx_id(receipt.reference_sale).company_id
        elsif PlanLog.find_by_trx_id(receipt.reference_sale)
          plan_log = PlanLog.find_by_trx_id(receipt.reference_sale).company_id
      when "PuntoPagosConfirmation"
        if BillingLog.find_by_trx_id(receipt.trx_id)
          billing_log = BillingLog.find_by_trx_id(receipt.trx_id).company_id
        elsif PlanLog.find_by_trx_id(receipt.trx_id)
          plan_log = PlanLog.find_by_trx_id(receipt.trx_id).company_id
      end
      company = Company.find(company_id)
    end

    def self.payment_method(receipt, type)
      if type == "PayUNotification"
        receipt.payment_method_name
      else
        code_to_payment_method(receipt.payment_method)
      end
    end
end
