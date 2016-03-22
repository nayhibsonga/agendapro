class CompanyMailer < Base::CustomMailer
  layout "mailers/agendapro"

  include ApplicationHelper

  #Send a warning notifying tht trial period ends soon (5 days)
  def warning_trial (company, recipient)
    # layout variables
    @title = "Comprobante de pago en Agendapro"
    @header = "Aviso de fin del período de prueba. Si ya activaste tu cuenta, por favor ignora este correo."

    # view variables
    @chile = company.country.name == "Chile"

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  #Send end of trial notification
  def end_trial (company, recipient)
    # layout variables
    @title = "Fin del período de prueba en AgendaPro"
    @header = "Aviso de fin del período de prueba. Si ya activaste tu cuenta, por favor ignora este correo."

    # view variables
    @chile = company.country.name == "Chile"
    @company = company
    @admin = @company.users.where(role_id: Role.find_by_name('Administrador General')).first
    sales_tax = company.country.sales_tax
    @plan_amount = company.company_plan_setting.base_price * company.computed_multiplier * (1 + sales_tax)

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  #Send a warning notifying tht trial period ends soon (5 days)
  def recovery_trial (company, recipient)
    # layout variables
    @title = "¿Necesitas ayuda con tu cuenta AgendaPro?"
    @header = "Plan de prueba AgendaPro."

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  #Send invoice_email charging for new month.
  def invoice (company, recipient)
    invoice_common (company)

    # layout variables
    @title = "¡Ya puedes pagar tu cuenta AgendaPro!"

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def message_invoice(company, recipient)
    invoice_common (company)

    # layout variables
    @title = "Recordatorio de cuenta AgendaPro"
    # view variables
    @message = "Recuerda que tu cuenta ya fue enviada. Por favor paga a la brevedad para que no tengas problemas con tu servicio"

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def reminder_message_invoice(company, recipient)
    invoice_common (company)

    # layout variables
    @title = "Recordatorio de cuenta AgendaPro"
    # view variables
    @message = "Tu cuenta fue enviada el 1° del mes. Por favor paga a la brevedad para que no tengas problemas con tu servicio"

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def insistence_message_invoice(company, recipient)
    invoice_common (company)

    # layout variables
    @title = "Recordatorio de cuenta AgendaPro"
    # view variables
    @message = "Tu cuenta está atrasada de pago por un mes. Si quieres continuar usando tu plan con todas sus características, por favor ponte al día en el pago"

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def warning_message_invoice(company, recipient)
    invoice_common (company)

    # layout variables
    @title = "Recordatorio de cuenta AgendaPro"
    # view variables
    @message = "Tu cuenta fue enviada el 1° del mes. Si no cancelas el mes en curso dentro de los próximos días, tu plan actual será desactivado y sólo tendrás acceso básico a tu calendario. Por favor paga a la brevedad para que no tengas problemas con tu servicio"

    mail(
      from: filter_sender(),
      reply_to: filter_sender("cuentas@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def close_message_invoice(company, recipient)
    invoice_common (company)

    # layout variables
    @title = "Recordatorio de cuenta AgendaPro"
    # view variables
    @message = "Tu plan se ha desactivado por no pago. Aún puedes entrar a tu cuenta, pero sólo tendrás disponible el uso del calendario para revisar tus reservas. Si quieres reactivar tu plan, por favor cancela la deuda y el proporcional para el mes actual"

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
    company = Company.find(company_id)
    admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
    admin = admins.first

    punto_pagos_confirmation = PuntoPagosConfirmation.find(punto_pagos_confirmation_id)
    amount = punto_pagos_confirmation.amount

    current_date = DateTime.now
    day_number = Time.now.day
      month_days = Time.now.days_in_month

    # => Template
    template_name = 'online_receipt'
    template_content = []

    is_chile = true
    if company.country.name != "Chile"
      is_chile = false
    end

    auth_code = "NA"
    if !punto_pagos_confirmation.authorization_code.nil? && punto_pagos_confirmation.authorization_code != ""
      auth_code = punto_pagos_confirmation.authorization_code
    end

    recipients = []
    admins.each do |user|
        recipients << {
          :email => user.email,
          :name => user.full_name,
          :type => 'to'
        }
      end

      recipients << {
        :email => 'cuentas@agendapro.cl',
        :name => 'Cuentas AgendaPro',
        :type => 'to'
      }

    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :subject => 'Comprobante de pago de cuenta AgendaPro ' + company.name,
      :to => recipients,
      :headers => { 'Reply-To' => 'contacto@agendapro.cl' },
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
          :name => 'COMPANY',
          :content => company.name
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
          :name => 'PAYMENT_METHOD',
          :content => code_to_payment_method(punto_pagos_confirmation.payment_method)
        },
        {
          :name => 'CARD_NUMBER',
          :content => "********#{punto_pagos_confirmation.card_number}"
        },
        {
          :name => 'ORDER',
          :content => punto_pagos_confirmation.operation_number
        },
        {
          :name => 'AUTH_CODE',
          :content => auth_code
        },
        {
          :name => 'DATE',
          :content => punto_pagos_confirmation.created_at.strftime('%d/%m/%Y %R')
        },
        {
          :name => 'CHILE',
          :content => is_chile
        }
      ],
      :tags => []
    }

    # => Send mail
    send_mail(template_name, template_content, message)
  end

  def pay_u_online_receipt_email(company_id, pay_u_notification_id)
    company = Company.find(company_id)
    admins = company.users.where(role_id: Role.find_by_name('Administrador General'))
    admin = admins.first

    pay_u_notification = PayUNotification.find(pay_u_notification_id)
    amount = pay_u_notification.value

    current_date = DateTime.now
    day_number = Time.now.day
      month_days = Time.now.days_in_month

      card_number = "NA"
      if !pay_u_notification.cc_number.nil?
        card_number = "********#{pay_u_notification.cc_number}"
      end

      is_chile = true
    if company.country.name != "Chile"
      is_chile = false
    end

    # => Template
    template_name = 'online_receipt'
    template_content = []

    recipients = []
    admins.each do |user|
        recipients << {
          :email => user.email,
          :name => user.full_name,
          :type => 'to'
        }
      end

      recipients << {
        :email => 'cuentas@agendapro.cl',
        :name => 'Cuentas AgendaPro',
        :type => 'to'
      }

      auth_code = "NA"
      if !pay_u_notification.authorization_code.nil? && pay_u_notification.authorization_code != ""
        auth_code = pay_u_notification.authorization_code
      end

    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :subject => 'Comprobante de pago de cuenta AgendaPro',
      :to => recipients,
      :headers => { 'Reply-To' => 'contacto@agendapro.cl' },
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
          :name => 'COMPANY',
          :content => company.name
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
          :name => 'PAYMENT_METHOD',
          :content => pay_u_notification.payment_method_name
        },
        {
          :name => 'CARD_NUMBER',
          :content => card_number
        },
        {
          :name => 'AUTH_CODE',
          :content => auth_code
        },
        {
          :name => 'DATE',
          :content => pay_u_notification.created_at.strftime('%d/%m/%Y %R')
        },
        {
          :name => 'CHILE',
          :content => false
        }
      ],
      :tags => []
    }
    send_mail(template_name, template_content, message)
  end

  private
    def invoice_common (company)
      # layout variables
      @header = "Notificación cobro mes de #{(l DateTime.now, :format => '%B').capitalize}. Si ya pagaste, por favor ignora este correo. Los pagos pueden tardar en actualizarse por el sistema."

      # view variables
      @chile = company.country.name == "Chile"
      @company = company
      @admin = @company.users.where(role_id: Role.find_by_name('Administrador General')).first
      sales_tax = @company.country.sales_tax
      day_number = Time.now.day
      month_days = Time.now.days_in_month
      @plan_amount = @company.company_plan_setting.base_price * @company.computed_multiplier * (1 + sales_tax)
      if @company.plan_id == Plan.find_by_name("Gratis").id
        downgradeLog = DowngradeLog.where(company_id: @company.id).order('created_at desc').first
        if downgradeLog.present?
          prev_plan = Plan.find(downgradeLog.plan_id)
          price = prev_plan.plan_countries.find_by(country_id: @company.country.id).price
          @plan_amount = ((month_days.to_f - day_number + 1) / month_days.to_f) * price * (1 + sales_tax)
        end
      end
      @current_amount = @plan_amount + @company.due_amount
    end
end
