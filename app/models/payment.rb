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

  validates :payment_date, :location_id, :client_id, :presence => true

  after_save :set_numbers

  def set_numbers
    bookings_total = 0
    self.bookings.each do |booking|
      bookings_total += booking.service.price
    end
    bookings_amount = self.bookings.sum(:price)
    bookings_quantity = self.bookings.count
    bookings_discount = bookings_total > 0 ? 100 - 100 * bookings_amount / bookings_total : 0
    
    products_total = 0
    self.payment_products.each do |payment_product|
      products_total += payment_product.product.price * payment_product.quantity
    end
    products_amount = self.payment_products.sum(:price)
    products_quantity = self.payment_products.sum(:quantity)
    products_discount = products_total > 0 ? 100 - 100 * products_amount / products_total : 0

    amount = bookings_amount + products_amount
    quantity = bookings_quantity + products_quantity
    discount = ( bookings_total + products_total ) > 0 ? 100 - 100 * amount / ( bookings_total + products_total ) : 0

    self.update_columns(amount: amount, discount: discount, quantity: quantity, bookings_amount: bookings_amount, bookings_quantity: bookings_quantity, bookings_discount: bookings_discount, products_amount: products_amount, products_quantity: products_quantity, products_discount: products_discount)
  end
end
