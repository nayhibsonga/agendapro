class Payment < ActiveRecord::Base
  belongs_to :company
  has_many :receipts
  belongs_to :payment_method
  belongs_to :payment_method_type
  belongs_to :company_payment_method
  belongs_to :bank
  belongs_to :client
  belongs_to :location
  has_many :bookings, dependent: :nullify

  has_many :payment_products, dependent: :destroy
  has_many :products, through: :payment_products

  has_many :mock_bookings

  belongs_to :cashier

  accepts_nested_attributes_for :payment_products, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :bookings, :reject_if => :all_blank
  accepts_nested_attributes_for :mock_bookings, :reject_if => :all_blank

  validate :payment_date_required, :location_required

  #after_save :set_numbers

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


    #Check emails correctness. If any doesn't match, return false

    emails = []
    emails_arr = given_emails.split(',')

    emails_arr.each do |email|
      email_str = email.strip
      if email_str != ""
        emails << email_str
      end
    end

    summary = '';

    self.receipts.each do |receipt|

      summary << '<div class="receiptFinal" style="margin-bottom: 15px; border: 1px solid #fff; padding: 20px; text-align: center;"><div><span class="receiptTitle" style="text-align: center; font-weight: bold; font-size: 18px;">' + receipt.receipt_type.name + '</span><span class="receiptNumber" style="font-size: 18px; float: right;">N° ' + receipt.number + '</span></div><div><br /><div class="responsive-table" style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;min-height:.01%;overflow-x:auto;width:100%;overflow-y:hidden;-ms-overflow-style:-ms-autohiding-scrollbar;min-width:440px;"><table class="table summary" style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;border-spacing:0;border-collapse:collapse;font-family:"Roboto Condensed", sans-serif;font-size:12px;font-weight:300;width:100%;max-width:100%;color:#626262;background-color:transparent !important;background-image:none !important;background-repeat:repeat !important;background-position:top left !important;background-attachment:scroll !important;margin-bottom:0;">'
      summary << '<thead style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;"><tr  style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;"><th>Nombre</th><th>Precio unitario</th><th>Cantidad</th><th>Descuento</th><th>Subtotal</th></tr></thead>'

      receipt.payment_products.each do |payment_product|
        summary << '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;"><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + payment_product.product.name + '</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">$ ' + payment_product.product.price.to_s + '</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + payment_product.quantity.to_s + '</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + payment_product.discount.to_s + ' %<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">$ ' + (payment_product.price*(100-payment_product.discount)/100).round(1).to_s + '</td></tr>'
      end

      receipt.bookings.each do |booking|
        summary << '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;"><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + booking.name + '</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">$ ' + booking.list_price.to_s + '</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">1</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + booking.discount.to_s + ' %</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">$ ' + booking.price.to_s + '</td></tr>'
      end

      receipt.mock_bookings.each do |mock_booking|

        service_name = "Sin servicio"
        provider_name = "Sin proveedor"

        if !mock_booking.service_id.nil?
          service_name = mock_booking.service.name
        end
        if ! mock_booking.service_provider_id.nil?
          provider_name = mock_booking.service_provider.name
        end

        summary << '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;"><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + service_name + '</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">$' + mock_booking.price.to_s + '</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">1</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + mock_booking.discount.to_s + ' %</td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">$' + (mock_booking.price*(100-mock_booking.discount)/100).round(1).to_s + '</td></tr>'
      end

      summary << '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;"><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;"></td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;"></td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;"></td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;"><b>Total</b></td><td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;"><b>$' + receipt.amount.to_s + '</b></td></tr>'

      summary << '</table></div></div></div>'

    end

    PaymentsSystemMailer.receipts_email(self, emails, summary)
    
  end

end
