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
end
