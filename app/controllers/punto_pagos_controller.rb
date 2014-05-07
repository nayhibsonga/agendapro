class PuntoPagosController < ApplicationController
  def generate_transaction
  	trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
  	amount = '10000.00'
    payment_method = '1'
  	req = PuntoPagos::Request.new()
  	resp = req.create(trx_id, amount, payment_method)

  	if resp.success?
  		redirect_to resp.payment_process_url
    else
      puts resp.get_error
      puts resp[:error]
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
