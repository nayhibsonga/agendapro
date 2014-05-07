class PuntoPagosController < ApplicationController
  def generate_transaction
  	trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
    puts trx_id
  	amount = '10000.00'
    payment_method = '3'
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
    notification = PuntoPagos::Notification.new
    notification.valid? headers, params
  end
end
