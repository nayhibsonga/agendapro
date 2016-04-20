class ProductLog < ActiveRecord::Base
  belongs_to :product
  belongs_to :internal_sale
  belongs_to :payment_product
  belongs_to :service_provider
  belongs_to :client
  belongs_to :user

  def details
    #Check for internal_sale or payment_product presence.
    #Beware of dead ids (nullify them)
    details_str = "Sin detalles."
    if !self.internal_sale_id.nil? && InternalSale.where(id: self.internal_sale_id).count > 0
      details_str = "Comprador: " + self.internal_sale.buyer_details
      details_str += " - Cajero: " + self.internal_sale.cashier_details
    elsif !self.payment_product_id.nil? && PaymentProduct.where(id: self.payment_product_id).count > 0
      details_str = "Cliente: "
      if self.payment_product.payment.client.nil?
        details_str += "sin información."
      else
        details_str += self.payment_product.payment.client.full_name
      end
      details_str += " - Vendedor: " + self.payment_product.get_seller_details
    end

    return details_str
  end

end
