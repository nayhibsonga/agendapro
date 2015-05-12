class NotificationEmail < ActiveRecord::Base
  belongs_to :company

  has_many :notification_locations, dependent: :destroy
  has_many :locations, :through => :notification_locations

  has_many :notification_providers, dependent: :destroy
  has_many :service_providers, :through => :notification_providers

  validates :email, :receptor_type, :presence => true
  validate :location_company_notifications, :provider_company_notifications

  def location_company_notifications
    # receptor_type: 0 = company, 1 = locations, 2 = providers
    if self.receptor_type == 1
      if self.locations.empty?
        errors.add(:base, "Este tipo de receptor debe tener al menos un local asociado.")
      end
    else
      if !self.locations.empty?
        errors.add(:base, "Este tipo de receptor no debe tener ningún local asociado.")
      end
    end
  end

  def provider_company_notifications
    # receptor_type: 0 = company, 1 = locations, 2 = providers
    if self.receptor_type == 2
      if self.service_providers.empty?
        errors.add(:base, "Este tipo de receptor debe tener al menos un prestador asociado.")
      end
    else
      if !self.service_providers.empty?
        errors.add(:base, "Este tipo de receptor no debe tener ningún prestador asociado.")
      end
    end
  end

  def notification_text
    text = ""
    if self.summary
      text += "Resumen diario, "
    end
    if self.new
      text += "Nueva reserva manual, "
    end
    if self.modified
      text += "Reserva manual modificada, "
    end
    if self.confirmed
      text += "Reserva manual confirmada, "
    end
    if self.canceled
      text += "Reserva manual cancelada, "
    end
    if self.new_web
      text += "Nueva reserva online, "
    end
    if self.modified_web
      text += "Reserva online modificada, "
    end
    if self.confirmed_web
      text += "Reserva online confirmada, "
    end
    if self.canceled_web
      text += "Reserva online cancelada, "
    end
    return text[0..-3]
  end
end
