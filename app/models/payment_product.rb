class PaymentProduct < ActiveRecord::Base
  belongs_to :payment
  belongs_to :product
  belongs_to :receipt

  # after_create :set_stock_create
  after_save :set_stock_update
  before_destroy :set_stock_destroy

  def get_seller_details
    if !self.seller_id.nil?
      if self.seller_type == 0
        return self.seller.public_name + " (proveedor)"
      else
        return self.seller.first_name + " " + self.seller.last_name + " (" + self.seller.role.name + ")"
      end
    else
      return "Sin información"
    end
  end

  def seller
    if self.seller_id.nil?
      return nil
    end

    if self.seller_type == 0
      return ServiceProvider.find(self.seller_id)
    else
      return User.find(self.seller_id)
    end

  end

  #Has seller:
  #    seller_id: 
  # => id for service_provider or user
  #    seller_type:
  # => 0: service_provider
  # => 1: user (staff, recepcionista, etc.)

  # def set_stock_create
  # 	if LocationProduct.where(location_id: self.payment.location, product: self.product).count > 0
  # 		location_product = LocationProduct.where(location_id: self.payment.location, product: self.product).first
  # 		location_product.stock = location_product.stock - self.quantity >= 0 ? location_product.stock - self.quantity : 0
  # 		location_product.save
  # 	end
  # end

  def set_stock_update
  # 	if self.changed.include?('payment_id')
  # 		if self.payment.nil?
  # 			if LocationProduct.where(location_id: Payment.find(self.changes[:payment_id][0]).location_id, product: self.product).count > 0
		#   		location_product = LocationProduct.where(location_id: Payment.find(self.changes[:payment_id][0]).location_id, product: self.product).first
		#   		location_product.stock = location_product.stock + self.quantity >= 0 ? location_product.stock + self.quantity : 0
		#   		location_product.save
		#   	end
  # 		else
	 #  		if LocationProduct.where(location_id: self.payment.location_id, product: self.product).count > 0
		#   		location_product = LocationProduct.where(location_id: self.payment.location_id, product: self.product).first
		#   		location_product.stock = location_product.stock - self.quantity >= 0 ? location_product.stock - self.quantity : 0
		#   		location_product.save
		#   	end
		# end
  # 	elsif self.changed.include?('quantity')
  # 		if LocationProduct.where(location_id: self.payment.location, product: self.product).count > 0
	 #  		location_product = LocationProduct.where(location_id: self.payment.location, product: self.product).first
	 #  		location_product.stock = location_product.stock - (self.changes[:quantity][1] - self.changes[:quantity][0]) >= 0 ? (self.changes[:quantity][1] - self.changes[:quantity][0]) : 0
	 #  		location_product.save
	 #  	end
  # 	end
  end

  def set_stock_destroy
  	if self.payment && LocationProduct.where(location_id: self.payment.location, product: self.product).count > 0
  		location_product = LocationProduct.where(location_id: self.payment.location, product: self.product).first
  		location_product.stock = location_product.stock + self.quantity
  		location_product.save
  	end
  end
end