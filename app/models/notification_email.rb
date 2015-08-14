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

  def receptor_type_text
    text = ""
    if self.receptor_type == 0
      text = "Compañía, "
    elsif self.receptor_type == 1
      self.locations.each do |local|
        text += local.name + ", "
      end
    else
      self.service_providers.each do |provider|
        text += provider.public_name + ", "
      end
    end
    return text[0..-3]
  end

  def self.booking_summary
    where(summary: true).each do |notification|
      if notification.company.active
        if notification.receptor_type == 0 # Company summary
          today_schedule = ''
          Booking.where(location_id: Location.where(company: notification.company, active: true).select(:id)).where("DATE(start) = DATE(?)", Time.now).where.not(status: Status.find_by(name: 'Cancelado')).order(:start).each do |booking|
            today_schedule += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service_provider.public_name + "</td>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
              "</tr>"
          end

          booking_summary = ''
          Booking.where(location_id: Location.where(company: notification.company, active: true).select(:id), updated_at: (Time.now - 1.day)..Time.now).order(:start).each do |booking|
            booking_summary += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service_provider.public_name + "</td>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
                "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
              "</tr>"
          end

          booking_data = {
            logo: 'public' + notification.company.logo.email.url,
            name: notification.company.name,
            to: notification.email,
            company: notification.company.name,
            url: notification.company.web_address
          }
          if booking_data[:logo].include? "logo_vacio"
            booking_data[:logo] = 'app/assets/images/logos/logodoble2.png'
          end
          if booking_summary.length > 0 or today_schedule.length > 0
            BookingMailer.booking_summary(booking_data, booking_summary, today_schedule)
          end
        elsif notification.receptor_type == 1 # Location summary
          Location.where(id: notification.locations.where(active: true)).each do |location|
            today_schedule = ''
            Booking.where(location: location).where("DATE(start) = DATE(?)", Time.now).where.not(status: Status.find_by(name: 'Cancelado')).order(:start).each do |booking|
              today_schedule += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service_provider.public_name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
                "</tr>"
            end

            booking_summary = ''
            Booking.where(location: location, updated_at: (Time.now - 1.day)..Time.now).order(:start).each do |booking|
              booking_summary += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service_provider.public_name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
                "</tr>"
            end

            booking_data = {
              logo: 'public' + notification.company.logo.email.url,
              name: location.name,
              to: notification.email,
              company: notification.company.name,
              url: notification.company.web_address
            }
            if booking_data[:logo].include? "logo_vacio"
              booking_data[:logo] = 'app/assets/images/logos/logodoble2.png'
            end
            if booking_summary.length > 0 or today_schedule.length > 0
              BookingMailer.booking_summary(booking_data, booking_summary, today_schedule)
            end
          end
        else # Service Provider summary
          ServiceProvider.where(id: notification.service_providers.where(active: true)).each do |provider|
            today_schedule = ''
            Booking.where(service_provider: provider).where("DATE(start) = DATE(?)", Time.now).where.not(status: Status.find_by(name: 'Cancelado')).order(:start).each do |booking|
              today_schedule += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service_provider.public_name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
                "</tr>"
            end
            booking_summary = ''
            Booking.where(service_provider: provider, updated_at: (Time.now - 1.day)..Time.now).order(:start).each do |booking|
              booking_summary += "<tr style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;'>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.client.first_name + ' ' + booking.client.last_name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service.name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.service_provider.public_name + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + I18n.l(booking.start) + "</td>" +
                  "<td style='-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;border-width:1px;border-style:solid;border-color:#ddd;'>" + booking.status.name + "</td>" +
                "</tr>"
            end

            booking_data = {
              logo: 'public' + notification.company.logo.email.url,
              name: provider.public_name,
              to: notification.email,
              company: notification.company.name,
              url: notification.company.web_address
            }
            if booking_data[:logo].include? "logo_vacio"
              booking_data[:logo] = 'app/assets/images/logos/logodoble2.png'
            end
            if booking_summary.length > 0 or today_schedule.length > 0
              BookingMailer.booking_summary(booking_data, booking_summary, today_schedule)
            end
          end
        end
      end
    end
  end
end
