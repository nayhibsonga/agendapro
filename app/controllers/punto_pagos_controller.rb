class PuntoPagosController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, :only => [:generate_company_transaction, :generate_plan_transaction]
  before_action :verify_is_admin, :only => [:generate_company_transaction, :generate_plan_transaction]
  def generate_transaction
  	trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
  	amount = '10000.00'
    payment_method = '03'
  	req = PuntoPagos::Request.new()
  	resp = req.create(trx_id, amount, payment_method)

  	if resp.success?
  		redirect_to resp.payment_process_url
    else
      puts resp.get_error
      redirect_to punto_pagos_failure_path
  	end
  end

  def generate_company_transaction
    amount = params[:amount].to_i
    payment_method = params[:mp]
    company = Company.find(current_user.company_id)
    company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).first.price : price = company.plan.price
    sales_tax = NumericParameter.find_by_name("sales_tax").value
    day_number = Time.now.day
    month_number = Time.now.month
    month_days = Time.now.days_in_month
    accepted_amounts = [1,2,3,4,6,9,12]
    accepted_payments = ["01","03","04","05","06","07"]
    if accepted_amounts.include?(amount) && accepted_payments.include?(payment_method) && company
      NumericParameter.find_by_name(amount.to_s+"_month_discount") ? month_discount = NumericParameter.find_by_name(amount.to_s+"_month_discount").value : month_discount = 0
      # trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '') + "c" + company.id.to_s + "p" + company.plan.id.to_s
      trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
      # due = '10000.00'
      company.months_active_left > 0 ? plan_1 = (company.due_amount + price*(1+sales_tax)).round(0) : plan_1 = ((company.due_amount + (month_days - day_number + 1)*price/month_days)*(1+sales_tax)).round(0)
      due = sprintf('%.2f', ((plan_1 + price*(amount-1)*(1+sales_tax))*(1-month_discount)).round(0))
      req = PuntoPagos::Request.new()
      resp = req.create(trx_id, due, payment_method)
      if resp.success?
        PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Creación de pago empresa id "+company.id.to_s+", nombre "+company.name+". Paga plan "+company.plan.name+"("+company.plan.id.to_s+") "+amount.to_s+" veces, por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
        redirect_to resp.payment_process_url
      else
        PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Error creación de pago empresa id "+company.id.to_s+", nombre "+company.name+". Paga plan "+company.plan.name+"("+company.plan.id.to_s+") "+amount.to_s+" veces, por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
        redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Porfavor ponte en contacto con contacto@agendapro.cl si el problema persiste. (6)"
      end
    else
      redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Porfavor ponte en contacto con contacto@agendapro.cl si el problema persiste. (7)"
    end
  end

  def generate_plan_transaction
    plan_id = params[:plan_id].to_i
    payment_method = params[:mp]
    puts params[:plan_id]
    puts payment_method
    company = Company.find(current_user.company_id)
    company.payment_status == PaymentStatus.find_by_name("Trial") ? price = Plan.where(locations: company.locations.where(active: true).count).where('service_providers >= ?', company.service_providers.where(active: true).count).first.price : price = company.plan.price
    new_plan = Plan.find(plan_id)
    sales_tax = NumericParameter.find_by_name("sales_tax").value
    day_number = Time.now.day
    month_number = Time.now.month
    month_days = Time.now.days_in_month
    accepted_plans = Plan.where(custom: false).pluck(:id)
    accepted_payments = ["00","01","03","04","05","06","07"]
    if accepted_plans.include?(plan_id) && accepted_payments.include?(payment_method) && company
      if company.service_providers.where(active: true).count <= new_plan.service_providers && company.locations.where(active: true).count <= new_plan.locations 
      
        previous_plan_id = company.plan.id
        months_active_left = company.months_active_left
        plan_value_left = (month_days - day_number + 1)*price/month_days + price*(months_active_left - 1)
        due_amount = company.due_amount
        plan_price = Plan.find(plan_id).price
        plan_month_value = (month_days - day_number + 1)*plan_price/month_days
        trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')

        if months_active_left > 0
          if plan_value_left > (plan_month_value + due_amount) && payment_method == "00"
            new_active_months_left = ((plan_value_left - plan_month_value - due_amount)/plan_price).floor + 1
            new_amount_due = -1*(((plan_value_left - plan_month_value - due_amount)/plan_price)%1)*plan_price
            company.plan_id = plan_id
            company.months_active_left = new_active_months_left
            company.due_amount = (new_amount_due).round(0)
            if company.save
              PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id)
              redirect_to select_plan_path, notice: "El plan nuevo plan fue seleccionado exitosamente."
            else
              redirect_to select_plan_path, notice: "El plan no pudo ser cambiado. Tienes más locales/proveedores activos que lo que permite el plan, o no tienes los permisos necesarios para hacer este cambio."
            end
          else
            if payment_method != "00"
              due = sprintf('%.2f', ((plan_month_value + due_amount - plan_value_left)*(1+sales_tax)).round(0))
              req = PuntoPagos::Request.new()
              resp = req.create(trx_id, due, payment_method)
              if resp.success?
                PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id)
                PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
                redirect_to resp.payment_process_url
              else
                PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Error creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
                redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Porfavor ponte en contacto con contacto@agendapro.cl si el problema persiste. (1)"
              end
            else
              redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Porfavor ponte en contacto con contacto@agendapro.cl si el problema persiste. (2)"
            end
          end
        else
          if payment_method != "00"
            due = sprintf('%.2f', ((plan_month_value + due_amount)*(1+sales_tax)).round(0))
            req = PuntoPagos::Request.new()
            resp = req.create(trx_id, due, payment_method)
            if resp.success?
              PlanLog.create(trx_id: trx_id, new_plan_id: plan_id, prev_plan_id: previous_plan_id, company_id: company.id)
              PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
              redirect_to resp.payment_process_url
            else
              PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Error creación de cambio de plan empresa id "+company.id.to_s+", nombre "+company.name+". Cambia de plan "+company.plan.name+"("+company.plan.id.to_s+"), por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
              redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Porfavor ponte en contacto con contacto@agendapro.cl si el problema persiste. (3)"
            end
          else
            redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Porfavor ponte en contacto con contacto@agendapro.cl si el problema persiste. (4)"
          end
        end
      else
        redirect_to select_plan_path, notice: "El plan no pudo ser cambiado. Tienes más locales/proveedores activos que lo que permite el plan, o no tienes los permisos necesarios para hacer este cambio."
      end
    else
      redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Porfavor ponte en contacto con contacto@agendapro.cl si el problema persiste. (5)"
    end
  end

  def success
    
  end

  def failure

  end

  def notification
    puts "Entra a notificacion"
    if params[:trx]
      puts params[:trx]
    end
    notification = PuntoPagos::Notification.new
    if headers.nil? then headers = {"headers"=>""} end
    if params.nil? then params = {"params"=>""} end
    if notification.valid? headers, params
      puts params[:trx]
    end
  end
end
