class LocationProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :location
  has_many :stock_emails, dependent: :destroy

  validates :stock, presence: true

  after_save :check_stock

  #Send notice to indicate stock is low
  #Switch flag to show alert was sent and should not be sent 
  #again until it goes down after having gone up
  def check_stock

    #Check that location has active quick sends.
    if !self.location.stock_alarm_setting.nil? && self.location.stock_alarm_setting.quick_send
      #Stock grew, reset flag
      if self.stock_was < self.stock
        self.update_column(:alert_flag, true)
      end
    
      #Check first for own settings
    	if !self.stock_limit.nil? && !self.alarm_email.nil?
    		if self.stock < self.stock_limit && self.alert_flag
          #Send alert and mark flag
          self.update_column(:alert_flag, false)
    			PaymentsSystemMailer.stock_alarm_email(self)

    		end
      else
        #Check for location settings
        if self.location.stock_alarm_setting.has_default_stock_limit && self.stock < self.location.stock_alarm_setting.default_stock_limit
          #Send alert and mark flag
          self.update_column(:alert_flag, false)
          PaymentsSystemMailer.stock_alarm_email(self)
        end
    	end

    end

  end

  def check_stock_for_reminder
    #Check that location has active quick sends.
    if !self.location.stock_alarm_setting.nil? && self.location.stock_alarm_setting.periodic_send

      #Check first for own settings
      if !self.stock_limit.nil? && !self.alarm_email.nil?
        if self.stock < self.stock_limit
          #Send alert and mark flag
          return true

        end
      else
        #Check for location settings
        if self.location.stock_alarm_setting.has_default_stock_limit && self.stock < self.location.stock_alarm_setting.default_stock_limit
          #Send alert and mark flag
          return true
        end
      end

    end
  end

end
