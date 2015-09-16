class LocationProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :location

  after_save :check_stock

  def check_stock
  	if !self.stock_limit.nil? && !self.alarm_email.nil?
  		if self.stock < self.stock_limit
  			#Send notice to indicate stock is low
  			UserMailer.stock_alarm_email(self)
  		end
  	end
  end

end
