class Payment < ActiveRecord::Base
  belongs_to :company
  belongs_to :receipt_type
  belongs_to :payment_method
  belongs_to :payment_method_type
  belongs_to :company_payment_method
  belongs_to :bank
  belongs_to :client
  belongs_to :location
  has_many :bookings, dependent: :nullify

  has_many :payment_products, dependent: :destroy
  has_many :products, through: :payment_products

  accepts_nested_attributes_for :payment_products, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :bookings, :reject_if => :all_blank

  validate :payment_date_required, :client_required, :location_required

  after_save :set_numbers

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
    quantity = bookings_quantity + sessions_quantity + products_quantity
    discount = ( bookings_total + sessions_total + products_total ) > 0 ? 100 - 100 * amount / ( bookings_total + sessions_total + products_total ) : 0

    self.update_columns(amount: amount, discount: discount, quantity: quantity, bookings_amount: bookings_amount, bookings_quantity: bookings_quantity, bookings_discount: bookings_discount, sessions_amount: sessions_amount, sessions_quantity: sessions_quantity, sessions_discount: sessions_discount, products_amount: products_amount, products_quantity: products_quantity, products_discount: products_discount)
  end
end
