class PuntoPagosController < ApplicationController
  def generate_transaction
  	trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '')
  	amount = @booking.service.price.to_s + '.00'
    payment_method = '1'
  	req = PuntoPagos::Request.new()
  	resp = req.create(trx_id, amount, payment_method)

  	if resp.success?
  		redirect_to resp.payment_process_url
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
