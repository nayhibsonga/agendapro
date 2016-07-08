class Payment < ActiveRecord::Base
  belongs_to :company
  has_many :receipts, dependent: :destroy
  has_many :payment_transactions, dependent: :destroy
  belongs_to :client
  belongs_to :location
  has_many :bookings, dependent: :nullify

  has_many :payment_products, dependent: :destroy
  has_many :products, through: :payment_products

  has_many :mock_bookings, dependent: :destroy

  has_many :payment_sendings, dependent: :destroy

  #belongs_to :cashier
  belongs_to :employee_code

  accepts_nested_attributes_for :payment_products, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :bookings, :reject_if => :all_blank
  accepts_nested_attributes_for :mock_bookings, :reject_if => :all_blank

  validate :payment_date_required, :location_required

  #after_save :set_numbers

  def employee_code_details
    details_str = "Sin información."
    if !self.employee_code_id.nil? && EmployeeCode.where(id: self.employee_code_id).count > 0
      details_str = self.employee_code.name + "."
    end
    return details_str
  end

  def payment_date_required
    if self.payment_date == nil
      errors.add(:base, "El pago debe estar asociado a una fecha de pago.")
    end
  end

  def client_required
    if !self.client_id
      errors.add(:base, "El pago debe estar asociado a un cliente en particular.")
    end
  end

  def location_required
    if !self.location_id
      errors.add(:base, "El pago debe estar asociado a un local o sucursal.")
    end
  end

  def set_numbers
    bookings_total = 0
    self.bookings.where(is_session: false, session_booking_id: nil).each do |booking|
      bookings_total += booking.service.price
    end
    bookings_amount = self.bookings.where(is_session: false).sum(:price)
    bookings_quantity = self.bookings.count
    bookings_discount = bookings_total > 0 ? 100 - 100 * bookings_amount / bookings_total : 0

    sessions_total = 0
    sessions_amount = 0
    sessions_quantity = 0
    self.bookings.where.not(is_session: false, session_booking_id: nil).pluck(:session_booking_id).uniq.each do |session_booking_id|
      puts session_booking_id.to_s
      session_booking = SessionBooking.find(session_booking_id)
      sessions_total += session_booking.bookings.first.service.price
      sessions_amount += session_booking.bookings.first.price
      sessions_quantity += 1
    end
    sessions_discount = sessions_total > 0 ? 100 - 100 * sessions_amount / sessions_total : 0

    products_total = 0
    self.payment_products.each do |payment_product|
      products_total += payment_product.product.price * payment_product.quantity
    end
    products_amount = self.payment_products.sum(:price)
    products_quantity = self.payment_products.sum(:quantity)
    products_discount = products_total > 0 ? 100 - 100 * products_amount / products_total : 0

    amount = bookings_amount + sessions_amount + products_amount
    #Don't add sessions_quantity, it's implied in bookings
    quantity = bookings_quantity + products_quantity
    discount = ( bookings_total + sessions_total + products_total ) > 0 ? 100 - 100 * amount / ( bookings_total + sessions_total + products_total ) : 0

    self.update_columns(amount: amount, discount: discount, quantity: quantity, bookings_amount: bookings_amount, bookings_quantity: bookings_quantity, bookings_discount: bookings_discount, sessions_amount: sessions_amount, sessions_quantity: sessions_quantity, sessions_discount: sessions_discount, products_amount: products_amount, products_quantity: products_quantity, products_discount: products_discount)
  end

  def send_receipts_email(given_emails)
    PaymentSending.create(payment: self, emails: given_emails)
  end

  def self.generate_providers_report(company_id, service_providers, from, to, location_ids, filepath)

    require 'writeexcel'

    company = Company.find(company_id)
    title = filepath
    workbook = WriteExcel.new(title)

    worksheet1 = workbook.add_worksheet

    w1_header1 = ["","Total ventas de productos, reservas y servicios", "Total comisiones", "Total compras de productos"]

    worksheet1.write_row(0, 0, w1_header1)

    index1 = 1

    all_incomes_total = 0
    all_commissions_total = 0
    all_internal_sales_total = 0


    service_providers.each_with_index do |service_provider, index| 

      index1 += index
      
      payment_products = PaymentProduct.where(seller_id: service_provider.id, seller_type: 0, payment_id: Payment.where(payment_date: from.beginning_of_day..to.end_of_day, location_id: location_ids).pluck(:id))

      mock_bookings = MockBooking.where(service_provider_id: service_provider.id, payment_id: Payment.where(payment_date: from.beginning_of_day..to.end_of_day, location_id: location_ids).pluck(:id))

      bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado").id).where('payment_id is not null').where(service_provider_id: service_provider.id, payment_id: Payment.where(payment_date: from.beginning_of_day..to.end_of_day, location_id: location_ids).pluck(:id))

      internal_sales = InternalSale.where(service_provider_id: service_provider.id, date: from.beginning_of_day..to.end_of_day)

      payment_products_total = 0.0
      mock_bookings_total = mock_bookings.sum(:price)
      bookings_total = bookings.sum(:price)
      internal_sales_total = 0.0

      payment_products_commissions = 0.0
      mock_bookings_commissions = 0.0
      bookings_commissions = 0.0

      current_incomes_total = 0
      current_commissions_total = 0
      current_internal_sales_total = 0

      

      payment_products.each do |payment_product| 

        payment_products_total += payment_product.quantity * payment_product.price
        payment_products_commissions += payment_product.quantity * payment_product.product.get_commission

      end 

      mock_bookings.each do |mock_booking| 
        
        mock_bookings_commissions += mock_booking.get_commission
        
      end 

      bookings.each do |booking| 

        bookings_commissions += booking.get_commission
        
      end 

      internal_sales.each do |internal_sale| 

        internal_sales_total += internal_sale.quantity * internal_sale.price

      end 

      

      all_incomes_total += mock_bookings_total
      all_incomes_total += bookings_total
      all_incomes_total += payment_products_total

      all_commissions_total += payment_products_commissions
      all_commissions_total += bookings_commissions
      all_commissions_total += mock_bookings_commissions

      all_internal_sales_total += internal_sales_total

      current_incomes_total = mock_bookings_total + bookings_total + payment_products_total
      current_commissions_total = payment_products_commissions + bookings_commissions + mock_bookings_commissions
      current_internal_sales_total = internal_sales_total

      


      # <Row>
      #   <Cell><Data ss:Type="String"> service_provider.public_name </Data></Cell>
      #   <Cell><Data ss:Type="Number"> current_incomes_total.round(2) </Data></Cell>
      #   <Cell><Data ss:Type="Number"> current_commissions_total.round(2) </Data></Cell>
      #   <Cell><Data ss:Type="Number"> current_internal_sales_total.round(2) </Data></Cell>
      # </Row>
      sp_row = [service_provider.public_name, current_incomes_total.round(2), current_commissions_total.round(2), current_internal_sales_total.round(2)]
      worksheet1.write_row(index1, 0, sp_row)

    end 

    index1 += 1
    worksheet1.write(index1, 0, "")

    w1_header2 = ["TOTAL", all_incomes_total.round(2), all_commissions_total.round(2), all_internal_sales_total.round(2)]

    index1 += 1
    worksheet1.write_row(index1, 0, w1_header2)

    index1 += 1
    worksheet1.write(index1, 0, "")

    index1 += 1
    worksheet1.write(index1, 0, "Recaudaciones por fecha")

    sp_totals_row = [""]
    sp_totals_row2 = ["Fecha"]

    service_provider_totals = []
    sp_index = 0
    service_providers.order('public_name asc').each do |service_provider|
      service_provider_totals[sp_index] = [0, 0, 0]
      sp_index += 1
      sp_totals_row << service_provider.public_name
      sp_totals_row << ""
      sp_totals_row << ""
      sp_totals_row2 = sp_totals_row2 + ["Ventas", "Comisiones", "Compras internas"]
    end

    index1 += 1
    worksheet1.write_row(index1, 0, sp_totals_row)

    sp_totals_row2 = sp_totals_row2 + ["Total ventas", "Total comisiones", "Total compras internas"]

    index1 += 1
    worksheet1.write_row(index1, 0, sp_totals_row2)


    current_date = from.to_date
    end_date = to.to_date

    date_total_sum = 0
    date_commissions_total_sum = 0
    date_internal_sales_total_sum = 0

    while current_date <= end_date
      date_total = 0
      date_commissions_total = 0
      date_internal_sales_total = 0
      provider_index = 0

      provider_row = [current_date.strftime('%d/%m/%Y')]

      service_providers.order('public_name asc').each do |service_provider|

        payment_products = PaymentProduct.where(seller_id: service_provider.id, seller_type: 0, payment_id: Payment.where(payment_date: current_date.beginning_of_day..current_date.end_of_day, location_id: @location_ids).pluck(:id))

        mock_bookings = MockBooking.where(service_provider_id: service_provider.id, payment_id: Payment.where(payment_date: current_date.beginning_of_day..current_date.end_of_day, location_id: location_ids).pluck(:id))

        bookings = Booking.where.not(status_id: Status.find_by_name("Cancelado").id).where('payment_id is not null').where(service_provider_id: service_provider.id, payment_id: Payment.where(payment_date: current_date.beginning_of_day..current_date.end_of_day, location_id: location_ids).pluck(:id))

        internal_sales = InternalSale.where(service_provider_id: service_provider.id, date: current_date.beginning_of_day..current_date.end_of_day)


        payment_products_total = 0.0
        mock_bookings_total = mock_bookings.sum(:price)
        bookings_total = bookings.sum(:price)
        internal_sales_total = 0.0

        payment_products_commissions = 0.0
        mock_bookings_commissions = 0.0
        bookings_commissions = 0.0

        current_incomes_total = 0
        current_commissions_total = 0
        current_internal_sales_total = 0

        payment_products.each do |payment_product|


            payment_products_total += payment_product.quantity * payment_product.price
            payment_products_commissions += payment_product.quantity * payment_product.product.get_commission
        end


        mock_bookings.each do |mock_booking|
            mock_bookings_commissions += mock_booking.get_commission
        end


        bookings.each do |booking|
            bookings_commissions += booking.get_commission
        end

        internal_sales.each do |internal_sale|
            internal_sales_total += internal_sale.quantity * internal_sale.price
        end


        current_incomes_total = mock_bookings_total + bookings_total + payment_products_total
        current_commissions_total = payment_products_commissions + bookings_commissions + mock_bookings_commissions

        date_total += current_incomes_total
        date_commissions_total += current_commissions_total
        date_internal_sales_total += internal_sales_total

        service_provider_totals[provider_index][0] += current_incomes_total
        service_provider_totals[provider_index][1] += current_commissions_total
        service_provider_totals[provider_index][2] += internal_sales_total

        provider_row += [current_incomes_total, current_commissions_total, internal_sales_total]
        provider_index += 1

      end

      index1 += 1
      worksheet1.write_row(index1, 0, provider_row)

      date_total_sum += date_total
      date_commissions_total_sum += date_commissions_total
      date_internal_sales_total_sum += date_internal_sales_total
      current_date = current_date + 1.days

    end

    totals_final_row = ["Totales"]

    for i in 0..service_provider_totals.count-1
      totals_final_row += [service_provider_totals[i][0], service_provider_totals[i][1], service_provider_totals[i][2]]
    end

    totals_final_row += [date_total_sum, date_commissions_total_sum, date_internal_sales_total_sum]

    index1 += 1
    worksheet1.write_row(index1, 0, totals_final_row)

    workbook.close

    return workbook


  end

end
