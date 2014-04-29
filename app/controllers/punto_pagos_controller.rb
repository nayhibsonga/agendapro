class PuntoPagosController < ApplicationController
  def generate_transaction
  	@booking = Booking.find(params[:booking])

  	# => Datos de la transaccion
  	trx_id = DateTime.now.to_s.gsub(/[-:T]/i, '') + @booking.id.to_s
  	amount = @booking.service.price.to_s + '0'
  	# => Generamos la transaccion
  	req = PuntoPagos::Request.new()
  	resp = req.create(trx_id, amount)

  	if resp.success?
  		redirect_to resp.payment_process_url
  	end
  end

  def recieve_results
  	notification = PuntoPagos::Notification.new
    # This methods requires the headers as a hash and the params object as a hash
    notification.valid? headers, params
  end

  def success
    
  end

  def failure

  end

  def notification

  end
end
