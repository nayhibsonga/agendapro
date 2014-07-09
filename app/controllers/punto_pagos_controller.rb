class PuntoPagosController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, :only => :generate_company_transaction
  before_action :verify_is_admin, :only => :generate_company_transaction
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
    payment_method = params[:md]
    company = Company.find(current_user.company_id)
    sales_tax = NumericParameter.find_by_name("sales_tax").value
    accepted_amounts = [1,2,3,4,6,9,12]
    accepted_payments = ["01","03","04","05","06","07"]
    if accepted_amounts.include?(amount) && accepted_payments.include?(payment_method) && company
      NumericParameter.find_by_name(amount.to_s+"_month_discount") ? month_discount = NumericParameter.find_by_name(amount.to_s+"_month_discount").value : month_discount = 0
      # trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '') + "c" + company.id.to_s + "p" + company.plan.id.to_s
      trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
      # due = '10000.00'
      due = sprintf('%.2f', (company.plan.price*amount*(1-month_discount)*(1+sales_tax)).round(0))
      req = PuntoPagos::Request.new()
      resp = req.create(trx_id, due, payment_method)
      if resp.success?
        PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Creación de pago empresa id "+company.id.to_s+", nombre "+company.name+". Paga plan "+company.plan.name+"("+company.plan.id.to_s+") "+amount.to_s+" veces, por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: Se procesa")
        redirect_to resp.payment_process_url
      else
        PuntoPagosCreation.create(trx_id: trx_id, payment_method: payment_method, amount: due, details: "Creación de pago empresa id "+company.id.to_s+", nombre "+company.name+". Paga plan "+company.plan.name+"("+company.plan.id.to_s+") "+amount.to_s+" veces, por un costo de "+due+". trx_id: "+trx_id+" - mp: "+company.id.to_s+". Resultado: "+resp.get_error+".")
        redirect_to punto_pagos_failure_path
      end
    else
      redirect_to select_plan_path, notice: "No se pudo completar la operación ya que hubo un error en la solicitud de pago. Porfavor ponte en contacto con contacto@agendapro.cl si el problema persiste."
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
    notification.valid? headers.to_hash, params.to_hash
  end
end
