class ReceiptsPdf < Prawn::Document
	def initialize(receipt_id)

		font_families.update(
			"Roboto" => {
				normal: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Light.ttf')}", font: 'Roboto Condensed Light'},
				bold: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Bold.ttf')}", font: 'Roboto Condensed Bold'}
			}
		)
		super()
		font 'Roboto'

		@receipt = Receipt.find(receipt_id)

		header
		text_content

	end

	def header

		y_position = cursor
		bounding_box([220, y_position], width: 260, height: 30) do
			text "<b>" + @receipt.receipt_type.name + "</b>",
				:inline_format => true
		end
		bounding_box([440, y_position], width: 260, height: 30) do
			text "N° " + @receipt.number.to_s
		end

		move_down 10

		info_rows = []

		info_rows << ["Fecha: ", I18n.l(@receipt.date)]
		info_rows << ["Local: ", @receipt.payment.location.name]
		if !@receipt.payment.client_id.nil?
			info_rows << ["Cliente: " , @receipt.payment.client.first_name + " " + @receipt.payment.client.last_name]
			if !@receipt.payment.client.email.blank?
				info_rows << ["Email: ", @receipt.payment.client.email]
				move_down 5
			end
			if !@receipt.payment.client.phone
				info_rows << ["Teléfono: " + @receipt.payment.client.phone]
				move_down 5
			end
		end
		info_rows << ["Atendido por: ", @receipt.payment.cashier.name]

		table(info_rows) do
			cells.borders = []
		end

		move_down 10

	end

	def text_content
		table(receipt_table, header: true, position: :center, width: 540, :column_widths => [90,90,90,90,90,90]) do
			
			#cells.borders = []

			#columns(0..2).text_color = '000'
			#columns(0..2).borders = [:right]
			#columns(0..2).border_color = '000'

			row(0).font_style = :bold
			row(-1).font_style = :bold
			#row(0).text_color = '000'
			#row(0).background_color = 'fff'

			cells.row(0).borders = [:bottom]
			cells.row(-1).borders = [:top]
			#cells.column(0).align = :center
			#cells.style.size = 9
		end
	end

	def receipt_table

		table_header = [['Nombre', 'Vendedor/Prestador' 'Precio unitario', 'Cantidad', 'Descuento', 'Subtotal']]
		table_rows = []

		items_total = 0

		@receipt.payment_products.each do |payment_product|

			product_arr = []

			item_amount = (payment_product.quantity*payment_product.price*(100-payment_product.discount)/100).round

			items_total = items_total + item_amount

			product_arr << payment_product.product.name
			product_arr << payment_product.get_seller_details
			product_arr << '$ ' + payment_product.price.to_s
			product_arr << payment_product.quantity.to_s
			product_arr << payment_product.discount.to_s + '%'
			product_arr << '$ ' + item_amount.to_s

			table_rows.append(product_arr)

		end

		@receipt.mock_bookings.each do |mock_booking|

			mock_booking_arr = []

			item_amount = (mock_booking.price*(100-mock_booking.discount)/100).round

			items_total = items_total + item_amount

			if mock_booking.service_id.nil?
				mock_booking_arr << "Sin servicio"
			else
				mock_booking_arr << mock_booking.service.name
			end

			mock_booking_arr << '$' + mock_booking.price.to_s
			mock_booking_arr << '1'
			mock_booking_arr << mock_booking.discount.to_s + '%'
			mock_booking_arr << '$' + item_amount.to_s

			table_rows.append(mock_booking_arr)

		end

		@receipt.bookings.each do |booking|

			booking_arr = []

			item_amount = (booking.price*(100-booking.discount)/100).round

			items_total = items_total + item_amount

			booking_arr << booking.service.name
			booking_arr << '$' + booking.price.to_s
			booking_arr << '1'
			booking_arr << booking.discount.to_s + '%'
			booking_arr << '$' + item_amount.to_s

			table_rows.append(booking_arr)

		end

		total_row = ["", "", "", "", "Total", "$ " + @receipt.amount.to_s]
		table_rows.append(total_row)

		return table_header + table_rows

		text "the cursor is here: #{cursor}"

	end

end
