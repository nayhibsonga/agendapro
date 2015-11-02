module PaymentsHelper

	def provider_sales(provider_ids, from, to, time_option)

		service_providers = ServiceProvider.where(id: provider_ids)
		status_cancelled_id = Status.find_by_name("Cancelado")

		current_date = from.utc

		services = Hash.new
		products = Hash.new

		while current_date < to

			if time_option.nil? || !time_option || time_option == 0

				bookings_amount = Booking.where.not(status_id: status_cancelled_id).where('payment_id is not null').where(service_provider_id: provider_ids, start: current_date.beginning_of_day..current_date.end_of_day).sum(:price)

				mock_bookings_amount = MockBooking.where(service_provider_id: provider_ids, payment_id: Payment.where(payment_date: current_date).pluck(:id)).sum(:price)

				products_amount = PaymentProduct.where(seller_id: provider_ids, seller_type: 0, payment_id: Payment.where(payment_date: current_date).pluck(:id)).sum(:price)

				services_amount = bookings_amount + mock_bookings_amount
				total_amount = services_amount + products_amount

				services[current_date.beginning_of_day] = services_amount
				products[current_date.beginning_of_day] = products_amount

				current_date = current_date + 1.days

			else

				next_week = current_date + 1.weeks

				if next_week > to
					next_week = to
				end

				bookings_amount = Booking.where.not(status_id: status_cancelled_id).where('payment_id is not null').where(service_provider_id: provider_ids, start: current_date.beginning_of_day..next_week.end_of_day).sum(:price)

				mock_bookings_amount = MockBooking.where(service_provider_id: provider_ids, payment_id: Payment.where(payment_date: current_date..next_week).pluck(:id)).sum(:price)

				products_amount = PaymentProduct.where(seller_id: provider_ids, seller_type: 0, payment_id: Payment.where(payment_date: current_date..next_week).pluck(:id)).sum(:price)

				services_amount = bookings_amount + mock_bookings_amount
				total_amount = services_amount + products_amount

				services[current_date.beginning_of_day] = services_amount
				products[current_date.beginning_of_day] = products_amount

				current_date = next_week

			end

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

	def user_sales(user_ids, from, to, time_option)

		current_date = from.utc
		products = Hash.new

		while current_date < to

			if time_option.nil? || !time_option || time_option == 0

				products_amount = PaymentProduct.where(seller_id: user_ids, seller_type: 1, payment_id: Payment.where(payment_date: current_date).pluck(:id)).sum(:price)

				products[current_date.beginning_of_day] = products_amount

				current_date = current_date + 1.days

			else

				next_week = current_date + 1.weeks
				if next_week > to
					next_week = to
				end

				products_amount = PaymentProduct.where(seller_id: user_ids, seller_type: 1, payment_id: Payment.where(payment_date: current_date..next_week).pluck(:id)).sum(:price)

				products[current_date.beginning_of_day] = products_amount

				current_date = next_week

			end

		end

		return products

	end

	def cashier_sales(cashier_ids, from, to, time_option)

		current_date = from.utc
		products = Hash.new

		while current_date < to

			if time_option.nil? || !time_option || time_option == 0

				products_amount = PaymentProduct.where(seller_id: cashier_ids, seller_type: 2, payment_id: Payment.where(payment_date: current_date).pluck(:id)).sum(:price)

				products[current_date.beginning_of_day] = products_amount

				current_date = current_date + 1.days

			else

				next_week = current_date + 1.weeks
				if next_week > to
					next_week = to
				end

				products_amount = PaymentProduct.where(seller_id: cashier_ids, seller_type: 2, payment_id: Payment.where(payment_date: current_date..next_week).pluck(:id)).sum(:price)

				products[current_date.beginning_of_day] = products_amount

				current_date = next_week

			end

		end

		return products

	end

	#Sales Reporting
	def provider_sales_type_pie(service_provider_ids, from, to)

		#Obtain price sum for bookings, mock_bookings and products

		service_providers = ServiceProvider.where(id: service_provider_ids)

		count_bookings = 0
		count_mock_bookings = 0
		count_products = 0

		status_cancelled_id = Status.find_by_name("Cancelado").id

		count_bookings = Booking.where.not(status_id: status_cancelled_id).where('payment_id is not null').where(service_provider_id: service_provider_ids, start: from.beginning_of_day..to.end_of_day).sum(:price)
		count_mock_bookings = MockBooking.where(service_provider_id: service_provider_ids, payment_id: Payment.where(payment_date: from..to).pluck(:id)).sum(:price)

		payment_products = PaymentProduct.where(seller_id: service_provider_ids, seller_type: 0, payment_id: Payment.where(payment_date: from..to).pluck(:id))

		payment_products.each do |payment_product|
			count_products += payment_product.price * payment_product.quantity
		end

		count_hash = {
			"Servicios" => count_mock_bookings + count_bookings,
			"Productos" => count_products
		}

		return count_hash

	end

	def provider_commissions_pie(service_provider_ids, from, to)
		
		count_bookings = 0
		count_mock_bookings = 0
		count_products = 0

		status_cancelled_id = Status.find_by_name("Cancelado").id

		bookings = Booking.where.not(status_id: status_cancelled_id).where('payment_id is not null').where(service_provider_id: service_provider_ids, start: from.beginning_of_day..to.end_of_day)
		mock_bookings = MockBooking.where(service_provider_id: service_provider_ids, payment_id: Payment.where(payment_date: from..to).pluck(:id)).where('service_id is not null')
		payment_products = PaymentProduct.where(seller_id: service_provider_ids, seller_type: 0, payment_id: Payment.where(payment_date: from..to).pluck(:id))

		bookings.each do |booking|
			count_bookings += booking.get_commission
		end

		mock_bookings.each do |booking|
			count_bookings += booking.get_commission
		end

		payment_products.each do |payment_product|
			count_products += payment_product.quantity * payment_product.product.get_commission
		end

		count_hash = {
			"Servicios" => count_bookings,
			"Productos" => count_products
		}

		return count_hash

	end
end
