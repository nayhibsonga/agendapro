class ConvertOldNotificationToNew < ActiveRecord::Migration
  def change
    # Notificaciones por local
    Location.where(notification: true).where.not(bokking_configuration_email: 3) do |local|
      # Tipo de configuracion
      conf = local.booking_configuration_email
      if conf == 2
        conf = local.company.company_setting.booking_configuration_email
      end

      case conf
        when 0 # Transactional
          # Notification email
          notification = NotificationEmail.create(
              company: local.company,
              email: local.email,
              receptor_type: 2,
              summary: false,
              new: true,
              modified: true,
              confirmed: true,
              canceled: true,
              new_web: true,
              modified_web: true,
              confirmed_web: true,
              canceled_web: true
            )
          notification.save

          # Notification locations
          nLocation = NotificationLocation.create(
              location: local,
              notification_email: notification
            )
          nLocation.save
        when 1 # Summary
          # Notification email
          notification = NotificationEmail.create(
              company: local.company,
              email: local.email,
              receptor_type: 2
            )
          notification.save

          # Notification locations
          nLocation = NotificationLocation.create(
              location: local,
              notification_email: notification
            )
          nLocation.save
        else # No notification
          puts "The local {local.name} has set to no notification"
      end
    end

    # Notificacion por prestador
    Revisar los prestadores por local
    verificar si el email del prestador ya existe en la Notificacion
      Si existe, verificar si es tipo local o tipo prestador
      si es tipo prestador, incluir el prestador en la lista de prestadores
    Si no existe el email, generar la notificacion
  end
end
