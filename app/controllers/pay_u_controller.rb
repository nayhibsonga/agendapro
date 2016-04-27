class PayUController < ApplicationController
  require "net/http"
  require "net/https"
  require "uri"
  require 'digest/md5'

  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, :only => [:generate_company_transaction, :generate_plan_transaction]
  before_action :verify_is_admin, :only => [:generate_company_transaction, :generate_plan_transaction]

  #Métodos de pagos de reservas

  def generate_reservation_payment
    amount = params[:amount].to_i
    payment_method = params[:mp]
  end



  #Métodos de pagos de compañía/plan
  def generate_transaction
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    task = crypt.decrypt_and_verify(params[:encrypted_task])
    task = task.to_hash

    @merchantId = "558490"
    @accountId = "560923"
    @description = task[:description]
    @referenceCode = task[:reference]
    @amount = task[:amount]
    @tax = "0.00"
    @taxReturnBase = "0.00"
    @shipmentValue = "0.00"
    @currency = "COP"
    @lng = "es"
    @sourceUrl = task[:source_url]
    @buttonType = "SIMPLE"
    # “ApiKey~merchantId~referenceCode~amount~currency”.
    @signature = Digest::MD5.hexdigest('lcYvfI1vUATdee2D70HJLbh8Xp~' + @merchantId + '~' + @referenceCode + '~' + @amount + '~' + @currency)

    render layout: "empty"
  end

  def generate_company_transaction
    amount = params[:amount].to_i
    company = Company.find(current_user.company_id)

    if company.plan_id == Plan.find_by_name("Gratis").id
      redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor refresca la página para volver a intentarlo. Escríbenos a contacto@agendapro.cl si el problema persiste. (11)"
      return
    end

    #company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(custom: false, locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: company.country.id).price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price

    price = 0
    if company.payment_status == PaymentStatus.find_by_name("Trial")
      if company.locations.count > 1 || company.service_providers.count > 1
        price = Plan.where(name: "Normal", custom: false).first.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
      else
        price = Plan.where(name: "Personal", custom: false).first.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
      end
    else
      if company.plan.custom
        price = company.company_plan_setting.base_price
      else
        price = company.company_plan_setting.base_price * company.computed_multiplier
      end
    end

    # sales_tax = NumericParameter.find_by_name("sales_tax").value
    sales_tax = company.country.sales_tax
    day_number = Time.now.day
    month_number = Time.now.month
    month_days = Time.now.days_in_month
    accepted_amounts = [1,2,3,4,6,9,12]
    if accepted_amounts.include?(amount) && company
      mockCompany = Company.find(current_user.company_id)
      mockCompany.months_active_left += amount
      mockCompany.due_amount = 0.0
      mockCompany.due_date = nil
      mockCompany.payment_status_id = PaymentStatus.find_by_name("Activo").id
      if !mockCompany.valid?
        redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (10)"
      else
        NumericParameter.find_by_name(amount.to_s+"_month_discount") ? month_discount = NumericParameter.find_by_name(amount.to_s+"_month_discount").value : month_discount = 0
        # trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '') + "c" + company.id.to_s + "p" + company.plan.id.to_s

        trx_comp = company.id.to_s + "0" + company.plan.id.to_s + "0"
        trx_offset = 4
        trx_date = DateTime.now.to_s.gsub(/[-:T]/i, '')
        trx_date = trx_date[0, trx_date.size - trx_offset]
        trx_date = trx_date[trx_date.size - 15 + trx_comp.size, trx_date.size]
        trx_id = trx_comp + trx_date

        if trx_id.size > 15
          trx_id = trx_id[0, 15]
        end

        #company.months_active_left > 0 ? plan_1 = (company.due_amount + price*(1+sales_tax)).round(0) : plan_1 = ((company.due_amount + (month_days - day_number + 1)*price/month_days)*(1+sales_tax)).round(0)
        #due = sprintf('%.2f', ((plan_1 + price*(amount-1)*(1+sales_tax))*(1-month_discount)).round(0))
        # req = PuntoPagos::Request.new()
        # resp = req.create(trx_id, due, payment_method)

        plan_1 = (company.due_amount + price*(1+sales_tax)).round(0)
        due = sprintf('%.2f', ((plan_1 + price*(amount-1)*(1+sales_tax))*(1-month_discount)).round(0))

        crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
        encrypted_data = crypt.encrypt_and_sign({reference: trx_id, description: "Pago plan " + company.plan.name, amount: due, source_url: select_plan_url})

        if encrypted_data
          BillingLog.create(payment: due, amount: amount, company_id: company.id, plan_id: company.plan.id, transaction_type_id: TransactionType.find_by_name("Webpay").id, trx_id: trx_id)
          PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Creación de pago empresa id "+company.id.to_s+", nombre "+company.name+". Paga plan "+company.plan.name+"("+company.plan.id.to_s+") "+amount.to_s+" veces, por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
          redirect_to action: 'generate_transaction', encrypted_task: encrypted_data
          return
        else
          PayUCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Error creación de pago empresa id "+company.id.to_s+", nombre "+company.name+". Paga plan "+company.plan.name+"("+company.plan.id.to_s+") "+amount.to_s+" veces, por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
          redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (6)"
          return
        end
      end
    else
      redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (7)"
      return
    end
  end

  def generate_plan_transaction
    plan_id = params[:plan_id].to_i
    company = Company.find(current_user.company_id)
    #company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).first.plan_countries.find_by(country_id: company.country.id).price: price = company.plan.plan_countries.find_by(country_id: company.country.id).price

    price = 0
    if company.payment_status == PaymentStatus.find_by_name("Trial")
      if company.locations.count > 1 || company.service_providers.count > 1
        price = Plan.where(name: "Normal", custom: false).first.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
      else
        price = Plan.where(name: "Personal", custom: false).first.plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
      end
    else
      if company.plan.custom
        price = company.company_plan_setting.base_price
      else
        price = company.company_plan_setting.base_price * company.computed_multiplier
      end
    end

    new_plan = Plan.find(plan_id)
    # sales_tax = NumericParameter.find_by_name("sales_tax").value
    sales_tax = company.country.sales_tax
    day_number = Time.now.day
    month_number = Time.now.month
    month_days = Time.now.days_in_month
    accepted_plans = Plan.where(custom: false).pluck(:id)
    if accepted_plans.include?(plan_id) && company
      if (company.service_providers.where(active: true, location_id: company.locations.where(active: true).pluck(:id)).count <= new_plan.service_providers && company.locations.where(active: true).count <= new_plan.locations) || (!new_plan.custom && new_plan.name != "Personal")

        previous_plan_id = company.plan.id
        months_active_left = company.months_active_left
        plan_value_left = (month_days - day_number + 1)*price/month_days + price*(months_active_left - 1)
        due_amount = company.due_amount
        plan_price = Plan.find(plan_id).plan_countries.find_by(country_id: company.country.id).price * company.computed_multiplier
        plan_month_value = (month_days - day_number + 1)*plan_price/month_days

        trx_comp = company.id.to_s + "0" + plan_id.to_s + "0"
        trx_offset = 4
        trx_date = DateTime.now.to_s.gsub(/[-:T]/i, '')
        trx_date = trx_date[0, trx_date.size - trx_offset]
        trx_date = trx_date[trx_date.size - 15 + trx_comp.size, trx_date.size]
        trx_id = trx_comp + trx_date

        if trx_id.size > 15
          trx_id = trx_id[0, 15]
        end

        if months_active_left > 0
          if plan_value_left > (plan_month_value + due_amount)

            new_active_months_left = ((plan_value_left - plan_month_value - due_amount/(1 + sales_tax)).round(0)/plan_price).floor + 1

            new_amount_due = (-1 * (((plan_value_left - plan_month_value - due_amount/(1 + sales_tax)).round(0)/plan_price) % 1 )) * plan_price * (1 + sales_tax)

            company.plan_id = plan_id
            company.months_active_left = new_active_months_left
            company.due_amount = (new_amount_due).round(0)

            if company.save
              company.company_plan_setting.base_price = company.plan.plan_countries.find_by_country_id(company.country.id).price
              company.company_plan_setting.save
              company.company_setting.mails_base_capacity = company.plan.monthly_mails
              company.company_setting.save
              PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id, amount: 0.0)
              redirect_to select_plan_path, notice: "El plan nuevo plan fue seleccionado exitosamente."
              return
            else
              redirect_to select_plan_path, notice: "El plan no pudo ser cambiado. Tienes más locales y/o prestadores activos que lo que permite el plan, o no tienes los permisos necesarios para hacer este cambio."
              return
            end
          else
            mockCompany = Company.find(current_user.company_id)
            mockCompany.plan_id = plan_id
            mockCompany.months_active_left = 1.0
            mockCompany.due_amount = 0.0
            mockCompany.due_date = nil
            mockCompany.payment_status_id = PaymentStatus.find_by_name("Activo").id
            if !mockCompany.valid?
              redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (8)"
            else
              due = sprintf('%.2f', ((plan_month_value + due_amount - plan_value_left)*(1+sales_tax)).round(0))
              # req = PuntoPagos::Request.new()
              # resp = req.create(trx_id, due, payment_method)
              crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
              encrypted_data = crypt.encrypt_and_sign({reference: trx_id, description: "Cambio a plan " + company.plan.name, amount: due, source_url: select_plan_path})
              if encrypted_data
                PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id, amount: due)
                PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
                redirect_to action: 'generate_transaction', encrypted_task: encrypted_data
                return
              else
                PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Error creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
                redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (1)"
                return
              end
            end
          end
        else
          mockCompany = Company.find(current_user.company_id)
          mockCompany.plan_id = plan_id
          mockCompany.months_active_left = 1.0
          mockCompany.due_amount = 0.0
          mockCompany.due_date = nil
          mockCompany.payment_status_id = PaymentStatus.find_by_name("Activo").id
          if !mockCompany.valid?
            redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (9)"
          else
            due = sprintf('%.2f', ((plan_month_value + due_amount)*(1+sales_tax)).round(0))
            # req = PuntoPagos::Request.new()
            # resp = req.create(trx_id, due, payment_method)
            crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
            encrypted_data = crypt.encrypt_and_sign({reference: trx_id, description: "Cambio a plan " + company.plan.name, amount: due, source_url: select_plan_path})
            if encrypted_data
              PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id, amount: due)
              PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
              redirect_to action: 'generate_transaction', encrypted_task: encrypted_data
            else
              PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Error creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
              redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (3)"
              return
            end
          end
        end
      else
        redirect_to select_plan_path, notice: "El plan no pudo ser cambiado. Tienes más locales y/o prestadores activos que lo que permite el plan, o no tienes los permisos necesarios para hacer este cambio."
        return
      end
    else
      redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (5)"
      return
    end
  end


  #Accepts a payment to reactivate a company, i.e. change it's plan from free to the old one
  def generate_reactivation_transaction

    payment_method = params[:mp]
    company = Company.find(current_user.company_id)

    downgradeLog = DowngradeLog.where(company_id: company.id).order('created_at desc').first

    new_plan = downgradeLog.plan

    #Should have free plan
    previous_plan = company.plan

    if new_plan.custom
      price = new_plan.plan_countries.find_by(country_id: company.country.id).price
    else
      price = new_plan.plan_countries.find_by(country_id: company.country.id).price  company.computed_multiplier
    end

    sales_tax = company.country.sales_tax

    day_number = Time.now.day
    month_number = Time.now.month
    month_days = Time.now.days_in_month

    plan_month_value = ((month_days - day_number + 1).to_f / month_days.to_f) * price
    due_amount = downgradeLog.debt


    if company
      mockCompany = Company.find(current_user.company_id)
      mockCompany.plan_id = new_plan.id
      mockCompany.months_active_left = 1.0
      mockCompany.due_amount = 0.0
      mockCompany.due_date = nil

      if !mockCompany.valid?
            redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (9)"
      else

        trx_comp = mockCompany.id.to_s + "0" + new_plan.id.to_s + "0"
        trx_offset = 4
        trx_date = DateTime.now.to_s.gsub(/[-:T]/i, '')
        trx_date = trx_date[0, trx_date.size - trx_offset]
        trx_date = trx_date[trx_date.size - 15 + trx_comp.size, trx_date.size]
        trx_id = trx_comp + trx_date

        if trx_id.size > 15
          trx_id = trx_id[0, 15]
        end

        due = sprintf('%.2f', ((plan_month_value + due_amount /(1 + sales_tax) )*(1 + sales_tax)).round(0))

        crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)

        encrypted_data = crypt.encrypt_and_sign({reference: trx_id, description: "Cambio a plan " + mockCompany.plan.name, amount: due, source_url: select_plan_path})


        if encrypted_data
          PlanLog.create(trx_id: trx_id, new_plan_id: new_plan.id, prev_plan_id: previous_plan.id, company_id: mockCompany.id, amount: due)
          PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Creación de reactivación de plan empresa id "+mockCompany.id.to_s+", nombre "+mockCompany.name+". Cambia de plan "+mockCompany.plan.name+"("+mockCompany.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+mockCompany.id.to_s+". Resultado: Se procesa")
          redirect_to action: 'generate_transaction', encrypted_task: encrypted_data
          return
        else
          PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Error creación de cambio de plan empresa id "+mockCompany.id.to_s+", nombre "+mockCompany.name+". Cambia de plan "+mockCompany.plan.name+"("+mockCompany.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+mockCompany.id.to_s+". Resultado: "+resp.get_error+".")
          redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (3)"
        end
      end
    end
  end


  def response_handler
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    encrypted_transaction = ''
    if PayUNotification.find_by_transaction_id(response_params[:transactionId])
      encrypted_transaction = crypt.encrypt_and_sign(PayUNotification.find_by_transaction_id(response_params[:transactionId]).reference_sale)
      pay_u_response = PayUResponse.create(response_params)
      if response_params[:transactionState] == "4"
          if PayUNotification.find_by_transaction_id(response_params[:transactionId]).state_pol == "4"
            redirect_to pay_u_success_path(encrypted_transaction: encrypted_transaction)
            return
          end
      elsif response_params[:transactionState] == "7"

      end
    end
    redirect_to pay_u_failure_path(encrypted_transaction: encrypted_transaction)
    return
  end

  def success
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    trx_id = crypt.decrypt_and_verify(params[:encrypted_transaction])
    if BillingLog.find_by_trx_id(trx_id)
      @billing_log = BillingLog.find_by_trx_id(trx_id)
      @company = Company.find(@billing_log.company_id)
      @success_page = "billing"
    elsif PlanLog.find_by_trx_id(trx_id)
      @plan_log = PlanLog.find_by_trx_id(trx_id)
      @company = Company.find(@plan_log.company_id)
      @success_page = "plan"
    elsif Booking.find_by_trx_id(trx_id)
      #Mostrar página similar a la de reserva hecha, confirmando que se pagó
      @bookings = Booking.where(:trx_id => trx_id)

      if @bookings.count > 0 && @bookings.first.marketplace_origin
        redirect_to 'http://' + ENV['MARKETPLACE_URL'] + '/booking/success/' + @bookings.first.id.to_s + '/' + @bookings.first.access_token
        return
      end

      @has_session_booking = false
      @session_booking = nil
      if @bookings.first.is_session
        @has_session_booking = true
        @session_booking = @bookings.first.session_booking
      end
      @token = params[:token]
      @success_page = "booking"
      host = request.host_with_port
      @url = @bookings.first.location.get_web_address + '.' + host[host.index(request.domain)..host.length]

      if !@bookings.first.booking_group.nil?
        not_payed_bookings = Booking.where(:booking_group => @bookings.first.booking_group, :payed => false)
        not_payed_bookings.each do |not_payed_booking|
          @bookings << not_payed_booking
        end
      end

      @try_register = false
      client = @bookings.first.client
      @company = @bookings.first.location.company

      if !user_signed_in?
        if !User.find_by_email(client.email)
          @try_register = true
          @user = User.new
          @user.email = client.email
          @user.first_name = client.first_name
          @user.last_name = client.last_name
          @user.phone = client.phone
        end
      end
      render layout: "workflow"
    else
      #Something (lie a booking) was deleted, should redirect to failure
      redirect_to action: 'failure', token: params[:token]
      #@success_page = ""
    end
  end

  def failure
    @token = ''
    if params[:encrypted_transaction].present?
      crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
      trx_id = crypt.decrypt_and_verify(params[:encrypted_transaction])
      @token = trx_id
      if trx_id.present?
        if(Booking.find_by_trx_id(trx_id))
          bookings = Booking.where(:trx_id => trx_id)

          if bookings.count > 0 && bookings.first.marketplace_origin
            redirect_to 'http://' + ENV['MARKETPLACE_URL'] + '/booking/failure/' + bookings.first.id.to_s + '/' + bookings.first.access_token
            return
          end

          @are_session_bookings = false
          if bookings.count > 0
            if bookings.first.is_session
              @are_session_bookings = true
            end
          end

          if @are_session_bookings
            session_booking = SessionBooking.find(bookings.first.session_booking_id)

            if !session_booking.treatment_promo_id.nil?
              treatment_promo = TreatmentPromo.find(session_booking.treatment_promo_id)
              treatment_promo.max_bookings = treatment_promo.max_bookings + 1
              treatment_promo.save
            end

            session_booking.delete

            bookings.each do |booking|
              booking.delete
            end

          else
            bookings.each do |booking|
              if !booking.service_promo_id.nil?
                service_promo = ServicePromo.find(booking.service_promo_id)
                service_promo.max_bookings = service_promo.max_bookings + 1
                service_promo.save
              end
              booking.delete
            end
          end

          #@bookings = Array.new
          #bookings.each do |failed_booking|
            #failed_booking = Booking.find_by_token(params[:token])
            #booking = Booking.new(failed_booking.attributes.to_options)
            #@bookings << booking
            #failed_booking.destroy
          #end
        end
      elsif Booking.find_by_token(params[:token]) #Cuando el servicio está caído y no hay notificación
        bookings = Booking.where(:token => params[:token])

        @are_session_bookings = false
        if bookings.count > 0
          if bookings.first.is_session
            @are_session_bookings = true
          end
        end

        if @are_session_bookings
          session_booking = SessionBooking.find(bookings.first.session_booking_id)

          if !session_booking.service_promo_id.nil?
            service_promo = ServicePromo.find(session_booking.service_promo_id)
            service_promo.max_bookings = service_promo.max_bookings + 1
            service_promo.save
          end

          session_booking.delete

          bookings.each do |booking|
            booking.delete
          end

        else
          bookings.each do |booking|
            if !booking.service_promo_id.nil?
              service_promo = ServicePromo.find(booking.service_promo_id)
              service_promo.max_bookings = service_promo.max_bookings + 1
              service_promo.save
            end
            booking.delete
          end
        end

        #@bookings = Array.new
        #bookings.each do |failed_booking|
          #failed_booking = Booking.find_by_token(params[:token])
          #booking = Booking.new(failed_booking.attributes.to_options)
          #@bookings << booking
          #failed_booking.destroy
        #end
      else
        #Nothing found, there was a timeout error
      end
    end
  end

  def confirmation
    pay_u_notification = PayUNotification.create(confirmation_params)
    render :nothing => true, :status => 200, :content_type => 'text/html'
    # punto_pagos_confirmation = PuntoPagosConfirmation.create(response: params[:respuesta], token: params[:token], trx_id: params[:trx_id], payment_method: params[:medio_pago], amount: params[:monto], approvement_date: params[:fecha_aprobacion], card_number: params[:numero_tarjeta], dues_number: params[:num_cuotas], dues_type: params[:tipo_cuotas], dues_amount:params[:valor_cuota], first_due_date: params[:primer_vencimiento], operation_number: params[:numero_operacion], authorization_code: params[:codigo_autorizacion])
    if confirmation_params[:state_pol] == "4"
      if BillingLog.find_by_trx_id(confirmation_params[:reference_sale])
        billing_log = BillingLog.find_by_trx_id(confirmation_params[:reference_sale])
        company = Company.find(billing_log.company_id)
        company.months_active_left += billing_log.amount
        company.due_amount = 0.0
        company.due_date = nil
        company.payment_status_id = PaymentStatus.find_by_name("Activo").id
        if company.save
          CompanyCronLog.create(company_id: company.id, action_ref: 7, details: "OK notification_billing")
          pay_u_notification.sendings.build(method: 'online_receipt').save
        else
          CompanyCronLog.create(company_id: company.id, action_ref: 7, details: "ERROR notification_billing "+company.errors.full_messages.inspect)
        end
      elsif PlanLog.find_by_trx_id(confirmation_params[:reference_sale])
        plan_log = PlanLog.find_by_trx_id(confirmation_params[:reference_sale])
        company = Company.find(plan_log.company_id)
        company.plan_id = plan_log.new_plan_id
        company.months_active_left = 1.0
        company.due_amount = 0.0
        company.due_date = nil
        company.payment_status_id = PaymentStatus.find_by_name("Activo").id
        if company.save
          company.company_plan_setting.base_price = company.plan.plan_countries.find_by_country_id(company.country.id).price
          company.company_plan_setting.save
          company.company_setting.mails_base_capacity = company.plan.monthly_mails
          company.company_setting.save
          CompanyCronLog.create(company_id: company.id, action_ref: 8, details: "OK notification_plan")
          pay_u_notification.sendings.build(method: 'online_receipt').save
        else
          CompanyCronLog.create(company_id: company.id, action_ref: 8, details: "ERROR notification_plan "+company.errors.full_messages.inspect)
        end
      elsif Booking.find_by_trx_id(confirmation_params[:reference_sale])

        #Creamos el registro de la reserva pagada.

        payed_booking = PayedBooking.new
        payed_booking.punto_pagos_confirmation = punto_pagos_confirmation
        payed_booking.transfer_complete = false
        payed_booking.save

        bookings = Array.new
        Booking.where(:trx_id => confirmation_params[:reference_sale]).each do |booking|
          booking.status_id = Status.find_by(:name => "Pagado").id
          booking.payed = true
          booking.payed_state = true
          booking.payed_booking = payed_booking
          booking.save
          bookings << booking
        end

        if bookings.count > 0

          if bookings.first.booking_group.nil?
            bookings.first.sendings.build(method: 'new_booking').save
          else
            if bookings.first.session_booking.nil?
              bookings.first.sendings.build(method: 'multiple_booking').save
            else
              bookings.first.session_booking.send_sessions_booking_mail
            end
          end

        else
          return
        end
        #Enviar comprobantes de pago
        payed_booking.payment_email

      end
    elsif pay_u_notification && pay_u_notification.id
      CompanyCronLog.create(company_id: nil, action_ref: 7, details: "ERROR notification_billing "+pay_u_notification.id.to_s)
    else
      CompanyCronLog.create(company_id: nil, action_ref: 7, details: "ERROR notification_billing")
    end
  end

  private

  def confirmation_params
    return params.permit(:merchant_id,  :state_pol,  :risk,  :response_code_pol,  :reference_sale,  :reference_pol,  :sign,  :extra1,  :extra2,  :payment_method,  :payment_method_type,  :installments_number,  :value,  :tax,  :additional_value,  :transaction_date,  :currency,  :email_buyer,  :cus,  :pse_bank,  :test,  :description,  :billing_address,  :shipping_address,  :phone,  :office_phone,  :account_number_ach,  :account_type_ach,  :administrative_fee,  :administrative_fee_base,  :administrative_fee_tax,  :airline_code,  :attempts,  :authorization_code,  :bank_id,  :billing_city,  :billing_country,  :commision_pol,  :commision_pol_currency,  :customer_number,  :date,  :error_code_bank,  :error_message_bank,  :exchange_rate,  :ip,  :nickname_buyer,  :nickname_seller,  :payment_method_id,  :payment_request_state,  :pseReference1,  :pseReference2,  :pseReference3,  :response_message_pol,  :shipping_city,  :shipping_country,  :transaction_bank_id,  :transaction_id,  :cc_number,  :cc_holder,  :bank_referenced_name,  :payment_method_name,  :antifraudMerchantId)
  end

  def response_params
    return params.permit(:merchantId, :transactionState, :risk, :polResponseCode, :referenceCode, :reference_pol, :signature, :polPaymentMethod, :polPaymentMethodType, :installmentsNumber, :TX_VALUE, :TX_TAX, :buyerEmail, :processingDate, :currency, :cus, :pseBank, :lng, :description, :lapResponseCode, :lapPaymentMethod, :lapPaymentMethodType, :lapTransactionState, :message, :extra1, :extra2, :extra3, :authorizationCode, :merchant_address, :merchant_name, :merchant_url, :orderLanguage, :pseCycle, :pseReference1, :pseReference2, :pseReference3, :telephone, :transactionId, :trazabilityCode, :TX_ADMINISTRATIVE_FEE, :TX_TAX_, :ADMINISTRATIVE_FEE, :TX_TAX_ADMINISTRATIVE, :_FEE_RETURN_BASE, :action_code_description, :cc_holder, :cc_number, :processing_date_time, :request_number)
  end
end
