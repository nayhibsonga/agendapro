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

    @merchantId = "540049"
    @accountId = "547737"
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
    @signature = Digest::MD5.hexdigest('5LG9s41B7yZWmYuLPs74I79dQE~' + @merchantId + '~' + @referenceCode + '~' + @amount + '~' + @currency)

    render layout: "empty"
  end

  def generate_company_transaction
    amount = params[:amount].to_i
    company = Company.find(current_user.company_id)
    company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(custom: false, locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).order(:service_providers).first.plan_countries.find_by(country_id: company.country.id).price : price = company.plan.plan_countries.find_by(country_id: company.country.id).price
    # sales_tax = NumericParameter.find_by_name("sales_tax").value
    sales_tax = 0
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

        company.months_active_left > 0 ? plan_1 = (company.due_amount + price*(1+sales_tax)).round(0) : plan_1 = ((company.due_amount + (month_days - day_number + 1)*price/month_days)*(1+sales_tax)).round(0)
        due = sprintf('%.2f', ((plan_1 + price*(amount-1)*(1+sales_tax))*(1-month_discount)).round(0))
        # req = PuntoPagos::Request.new()
        # resp = req.create(trx_id, due, payment_method)

        crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
        encrypted_data = crypt.encrypt_and_sign({reference: trx_id, description: "Pago plan " + company.plan.name, amount: due, source_url: select_plan_url})

        if encrypted_data
          BillingLog.create(payment: due, amount: amount, company_id: company.id, plan_id: company.plan.id, transaction_type_id: TransactionType.find_by_name("Webpay").id, trx_id: trx_id)
          PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Creación de pago empresa id "+company.id.to_s+", nombre "+company.name+". Paga plan "+company.plan.name+"("+company.plan.id.to_s+") "+amount.to_s+" veces, por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
          redirect_to action: 'generate_transaction', encrypted_task: encrypted_data
        else
          PayUCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Error creación de pago empresa id "+company.id.to_s+", nombre "+company.name+". Paga plan "+company.plan.name+"("+company.plan.id.to_s+") "+amount.to_s+" veces, por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
          redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (6)"
        end
      end
    else
      redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (7)"
    end
  end

  def generate_plan_transaction
    plan_id = params[:plan_id].to_i
    company = Company.find(current_user.company_id)
    company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).first.plan_countries.find_by(country_id: company.country.id).price: price = company.plan.plan_countries.find_by(country_id: company.country.id).price
    new_plan = Plan.find(plan_id)
    # sales_tax = NumericParameter.find_by_name("sales_tax").value
    sales_tax = 0
    day_number = Time.now.day
    month_number = Time.now.month
    month_days = Time.now.days_in_month
    accepted_plans = Plan.where(custom: false).pluck(:id)
    if accepted_plans.include?(plan_id) && company
      if company.service_providers.where(active: true).count <= new_plan.service_providers && company.locations.where(active: true).count <= new_plan.locations 
      
        previous_plan_id = company.plan.id
        months_active_left = company.months_active_left
        plan_value_left = (month_days - day_number + 1)*price/month_days + price*(months_active_left - 1)
        due_amount = company.due_amount
        plan_price = Plan.find(plan_id).plan_countries.find_by(country_id: company.country.id).price
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
            new_active_months_left = ((plan_value_left - plan_month_value - due_amount)/plan_price).floor + 1
            new_amount_due = -1*(((plan_value_left - plan_month_value - due_amount)/plan_price)%1)*plan_price
            company.plan_id = plan_id
            company.months_active_left = new_active_months_left
            company.due_amount = (new_amount_due).round(0)
            if company.save
              PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id)
              redirect_to select_plan_path, notice: "El plan nuevo plan fue seleccionado exitosamente."
            else
              redirect_to select_plan_path, notice: "El plan no pudo ser cambiado. Tienes más locales y/o prestadores activos que lo que permite el plan, o no tienes los permisos necesarios para hacer este cambio."
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
                PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id)
                PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
                redirect_to action: 'generate_transaction', encrypted_task: encrypted_data
              else
                PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Error creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
                redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (1)"
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
              PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id)
              PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
              redirect_to action: 'generate_transaction', encrypted_task: encrypted_data
            else
              PayUCreation.create(trx_id: trx_id, payment_method: '', amount: due, details: "Error creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
              redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (3)"
            end
          end
        end
      else
        redirect_to select_plan_path, notice: "El plan no pudo ser cambiado. Tienes más locales y/o prestadores activos que lo que permite el plan, o no tienes los permisos necesarios para hacer este cambio."
      end
    else
      redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Por favor escríbenos a contacto@agendapro.cl si el problema persiste. (5)"
    end
  end

  def success
    if params[:token]
      if PuntoPagosConfirmation.find_by_token(params[:token])
        trx_id = PuntoPagosConfirmation.find_by_token(params[:token]).trx_id
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
    end
  end

  def failure
    if PuntoPagosConfirmation.find_by_token(params[:token])
      trx_id = PuntoPagosConfirmation.find_by_token(params[:token]).trx_id
      if(Booking.find_by_trx_id(trx_id))
        bookings = Booking.where(:trx_id => trx_id)

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

  def confirmation
    pay_u_notification = PayUNotification.create(params.slice(:action, :controller))
    render :nothing => true, :status => 200, :content_type => 'text/html'
    # punto_pagos_confirmation = PuntoPagosConfirmation.create(response: params[:respuesta], token: params[:token], trx_id: params[:trx_id], payment_method: params[:medio_pago], amount: params[:monto], approvement_date: params[:fecha_aprobacion], card_number: params[:numero_tarjeta], dues_number: params[:num_cuotas], dues_type: params[:tipo_cuotas], dues_amount:params[:valor_cuota], first_due_date: params[:primer_vencimiento], operation_number: params[:numero_operacion], authorization_code: params[:codigo_autorizacion])
    # if params[:respuesta] == "00"
    #   if BillingLog.find_by_trx_id(params[:trx_id])
    #     billing_log = BillingLog.find_by_trx_id(params[:trx_id])
    #     company = Company.find(billing_log.company_id)
    #     company.months_active_left += billing_log.amount
    #     company.due_amount = 0.0
    #     company.due_date = nil
    #     company.payment_status_id = PaymentStatus.find_by_name("Activo").id
    #     if company.save
    #       CompanyCronLog.create(company_id: company.id, action_ref: 7, details: "OK notification_billing")
    #     else
    #       CompanyCronLog.create(company_id: company.id, action_ref: 7, details: "ERROR notification_billing "+company.errors.full_messages.inspect)
    #     end
    #   elsif PlanLog.find_by_trx_id(params[:trx_id])
    #     plan_log = PlanLog.find_by_trx_id(params[:trx_id])
    #     company = Company.find(plan_log.company_id)
    #     company.plan_id = plan_log.new_plan_id
    #     company.months_active_left = 1.0
    #     company.due_amount = 0.0
    #     company.due_date = nil
    #     company.payment_status_id = PaymentStatus.find_by_name("Activo").id
    #     if company.save
    #       CompanyCronLog.create(company_id: company.id, action_ref: 8, details: "OK notification_plan")
    #     else
    #       CompanyCronLog.create(company_id: company.id, action_ref: 8, details: "ERROR notification_plan "+company.errors.full_messages.inspect)
    #     end
    #   elsif Booking.find_by_trx_id(params[:trx_id])

    #     #Creamos el registro de la reserva pagada.

    #     payed_booking = PayedBooking.new
    #     payed_booking.punto_pagos_confirmation = punto_pagos_confirmation
    #     payed_booking.transfer_complete = false
    #     payed_booking.save

    #     bookings = Array.new
    #     Booking.where(:trx_id => params[:trx_id]).each do |booking|
    #       booking.status_id = Status.find_by(:name => "Pagado").id
    #       booking.payed = true
    #       booking.payed_booking = payed_booking
    #       booking.save
    #       bookings << booking
    #     end

    #     if bookings.count > 0

    #       if bookings.first.booking_group.nil?
    #         BookingMailer.book_service_mail(bookings.first)
    #       else
    #         if bookings.first.session_booking.nil?
    #           Booking.send_multiple_booking_mail(bookings.first.location_id, bookings.first.booking_group)
    #         else
    #           bookings.first.session_booking.send_sessions_booking_mail
    #         end
    #       end

    #     else
    #       #¿No bookings? There's an error
    #       redirect_to action: 'failure', token: params[:token]
    #       return
    #     end
    #     #Enviar comprobantes de pago
    #     BookingMailer.book_payment_mail(payed_booking)
    #     BookingMailer.book_payment_company_mail(payed_booking)
    #     BookingMailer.book_payment_agendapro_mail(payed_booking)
        
    #   end
    # end
  end
end
