class PuntoPagosController < ApplicationController
  skip_before_action :verify_authenticity_token
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
