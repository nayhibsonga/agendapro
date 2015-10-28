module PaymentsHelper

	def provider_sales(provider_ids, from, to)

		service_providers = ServiceProvider.where(id: provider_ids)
		status_cancelled_id = Status.find_by_name("Cancelado")

		current_date = from.utc

		services = Hash.new
		products = Hash.new

		while current_date < to

			bookings_amount = Booking.where.not(status_id: status_cancelled_id).where(service_provider_id: provider_ids, start: current_date.beginning_of_day..current_date.end_of_day).sum(:price)

			mock_bookings_amount = MockBooking.where(service_provider_id: provider_ids, payment_id: Payment.where(payment_date: current_date).pluck(:id)).sum(:price)

			products_amount = PaymentProduct.where(seller_id: provider_ids, seller_type: 0, payment_id: Payment.where(payment_date: current_date).pluck(:id)).sum(:price)

			services_amount = bookings_amount + mock_bookings_amount
			total_amount = services_amount + products_amount

			services[current_date.beginning_of_day] = services_amount
			products[current_date.beginning_of_day] = products_amount

			current_date = current_date + 1.days

		end
		
		count_hash = [{
			name: "Servicios",
			data: services
		},
		{
			name: "Productos",
			data: products
		}]

		return count_hash

	end

	def user_sales(user_ids, from, to)

		current_date = from.utc
		products = Hash.new

		while current_date < to

			products_amount = PaymentProduct.where(seller_id: user_ids, seller_type: 1, payment_id: Payment.where(payment_date: current_date).pluck(:id)).sum(:price)

			products[current_date.beginning_of_day] = products_amount

			current_date = current_date + 1.days

		end

		return products

	end

	def cashier_sales(cashier_ids, from, to)

		current_date = from.utc
		products = Hash.new

		while current_date < to

			products_amount = PaymentProduct.where(seller_id: cashier_ids, seller_type: 2, payment_id: Payment.where(payment_date: current_date).pluck(:id)).sum(:price)

			products[current_date.beginning_of_day] = products_amount

			current_date = current_date + 1.days

		end

		return products

	end

	#Sales Reporting
	def provider_sales_type_pie(provider_ids, from, to)

		#Obtain price sum for bookings, mock_bookings and products

		service_providers = ServiceProvider.where(id: provider_ids)

		count_bookings = 0
		count_mock_bookings = 0
		count_products = 0

		count_bookings = Booking.where(service_provider_id: provider_ids).sum(:price)
		count_mock_bookings = MockBooking.where(service_provider_id: provider_ids).sum(:price)
		payment_products = PaymentProduct.where(seller_id: provider_ids, seller_type: 0)

		payment_products.each do |payment_product|
			count_products += payment_product.price*payment_product.quantity
		end

		count_hash = {
			"Reservas" => count_bookings,
			"Servicios" => count_mock_bookings,
			"Productos" => count_products
		}

		return count_hash

	end

	def provider_commissions_pie(provider_ids, from, to)
		
		count_bookings = 0
		count_mock_bookings = 0
		count_products = 0

		bookings = Booking.where(service_provider_id: provider_ids)
		mock_bookings = MockBooking.where(service_provider_id: provider_ids).where('service_id is not null')
		payment_products = PaymentProduct.where(seller_id: provider_ids, seller_type: 0)

		bookings.each do |booking|
			service_commission = ServiceCommission.where(:service_provider_id => booking.service_provider_id, :service_id => booking.service_id).first

			if !service_commission.nil?
				if service_commission.is_percent
					count_bookings += booking.price*(service_commission.amount/100)
				else
					count_bookings += service_commission.amount
				end
			else
				if booking.service.comission_option == 0
					count_bookings += booking.price*(booking.service.comission_value/100)
				else
					count_bookings += booking.service.comission_value
				end
			end
		end

		mock_bookings.each do |booking|
			service_commission = ServiceCommission.where(:service_provider_id => booking.service_provider_id, :service_id => booking.service_id).first

			if !service_commission.nil?
				if service_commission.is_percent
					count_bookings += booking.price*(service_commission.amount/100)
				else
					count_bookings += service_commission.amount
				end
			else
				if booking.service.comission_option == 0
					count_bookings += booking.price*(booking.service.comission_value/100)
				else
					count_bookings += booking.service.comission_value
				end
			end
		end

		payment_products.each do |payment_product|
			if payment_product.product.comission_value == 0
				count_products += payment_product.price*(payment_product.product.comission_value/100)
			else
				count_products += payment_product.product.comission_value
			end
		end

		count_hash = {
			"Reservas" => count_bookings,
			"Servicios" => count_mock_bookings,
			"Productos" => count_products
		}

		return count_hash

	end
end
