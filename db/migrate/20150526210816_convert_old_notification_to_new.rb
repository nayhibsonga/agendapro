class ConvertOldNotificationToNew < ActiveRecord::Migration
  def change
    # Notificaciones por local
    puts "Editing locations"
    Location.where(notification: true, active: true).where.not(booking_configuration_email: 3).each do |local|
      # Tipo de configuracion
      conf = local.booking_configuration_email
      if conf == 2
        conf = local.company.company_setting.booking_configuration_email
      end

      # Notificacion correspondiente al local de la compañia, con unico email
      notification = NotificationEmail.where(company: local.company, email: local.email, receptor_type: 1)

      case conf
        when 0 # Transactional
          # Notification email
          notification = notification.where(summary: false).first
          unless notification
            notification = NotificationEmail.new(
                company: local.company,
                email: local.email,
                receptor_type: 1,
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
            notification.save(validate: false)
          end

          # Notification locations
          nLocation = NotificationLocation.create(
              location: local,
              notification_email: notification
            )
          nLocation.save
        when 1 # Summary
          # Notification email
          notification = notification.where(summary: true).first
          unless notification
            notification = NotificationEmail.new(
                company: local.company,
                email: local.email,
                receptor_type: 1
              )
            notification.save(validate: false)
          end

          # Notification locations
          nLocation = NotificationLocation.create(
              location: local,
              notification_email: notification
            )
          nLocation.save
        else # No notification
          puts "The local " + local.name + " has set to no notification"
      end
    end

    # Notificacion por prestador
    puts "Editing providers"
    ServiceProvider.where(active: true, location_id: Location.where(active: true)).where.not(booking_configuration_email: 3).order(:location_id).each do |provider|
      # Tipo de configuracion
      conf = provider.booking_configuration_email
      if conf == 2
        conf = provider.location.booking_configuration_email
        if conf == 2
          conf = provider.company.company_setting.booking_configuration_email
        end
      end

      # Notificacion correspondiente a prestadores de la compañia, con unico email
      notification = NotificationEmail.where(company: provider.company, email: provider.notification_email, receptor_type: 2)

      case conf
        when 0 # Transactional
          # Notification email
          notification = notification.where(summary: false).first
          unless notification
            notification = NotificationEmail.new(
                company: provider.company,
                email: provider.notification_email,
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
            notification.save(validate: false)
          end

          # Notification provider
          nProvider = NotificationProvider.create(
              service_provider: provider,
              notification_email: notification
            )
          nProvider.save
        when 1 # Summary
          # Notification email
          notification = notification.where(summary: true).first
          unless notification
            notification = NotificationEmail.new(
                company: provider.company,
                email: provider.notification_email,
                receptor_type: 2
              )
            notification.save(validate: false)
          end

          # Notification provider
          nProvider = NotificationProvider.create(
              service_provider: provider,
              notification_email: notification
            )
          nProvider.save
        else
          puts "Provider " + provider.public_name + " has set to no notification"
      end
    end
  end
end
