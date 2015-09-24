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
		bounding_box([220, y_position], width: 260, height: 50) do
			text @receipt.receipt_type.name
		end
		bounding_box([440, y_position], width: 260, height: 50) do
			text @receipt.number.to_s
		end

	end

	def text_content
		table(receipt_table, header: true, position: :center, width: 450, :column_widths => [90,90,90,90,90]) do
			
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

		table_header = [['Nombre', 'Precio unitario', 'Cantidad', 'Descuento', 'Subtotal']]
		table_rows = []

		items_total = 0

		@receipt.receipt_products.each do |receipt_product|

			product_arr = []

			item_amount = (receipt_product.quantity*receipt_product.price*(100-receipt_product.discount)/100).round

			items_total = items_total + item_amount

			product_arr << receipt_product.product.name
			product_arr << '$ ' + receipt_product.price.to_s
			product_arr << receipt_product.quantity.to_s
			product_arr << receipt_product.discount.to_s + '%'
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

		total_row = ["", "", "", "Total", "$ " + @receipt.amount.to_s]
		table_rows.append(total_row)

		return table_header + table_rows

	end

end
