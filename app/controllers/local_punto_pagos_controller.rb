class LocalPuntoPagosController < ApplicationController

	skip_before_action :verify_authenticity_token
	layout "home"

	def create_transaction

		token = SecureRandom.urlsafe_base64

		if !params[:trx_id].blank?

			@json_response = {
			    :respuesta => "00",
			    :token => token,
			    :trx_id => params[:trx_id],
			    :medio_pago => params[:medio_pago],
			    :monto => params[:monto]
			}

		else

			@json_response = {
			    :respuesta => "01",
			    :token => token,
			    :trx_id => "",
			    :medio_pago => "",
			    :monto => ""
			}

		end

		Rails.application.config.token = token
		Rails.application.config.trx_id = params[:trx_id]
		Rails.application.config.medio_pago = params[:medio_pago]
		Rails.application.config.monto = params[:monto]

		render :json => @json_response

	end

	def process_transaction
		@token = params[:token]
		@medio_pago = Rails.application.config.medio_pago
		@monto = Rails.application.config.monto
		@trx_id = Rails.application.config.trx_id
	end

	def notify

		respParams = {
			:token => params[:token],
			:trx_id => params[:trx_id],
			:medio_pago => params[:medio_pago],
			:monto => params[:monto],
			:fecha_aprobacion => params[:fecha],
			:numero_tarjeta => params[:numero_tarjeta],
			:num_cuotas => params[:numero_cuotas],
			:tipo_cuotas => params[:tipo_cuotas],
			:valor_cuota => params[:valor_cuota],
			:primer_vencimiento => params[:primer_vencimiento],
			:numero_operacion => params[:numero_operacion],
			:codigo_autorizacion => params[:codigo_autorizacion]
		}

		if params[:decision] == "accept"

			respParams[:respuesta] = "00"
			resp = RestClient.post 'http://lvh.me:3000/punto_pagos/notification', respParams

			redirect_to punto_pagos_success_trx_url(:token => respParams[:token])
			return
		else

			respParams[:respuesta] = "01"
			resp = RestClient.post 'http://lvh.me:3000/punto_pagos/notification', respParams

			redirect_to punto_pagos_failure_trx_url(:token => respParams[:token])
			return
		end

	end

	def after_notify

	end

end