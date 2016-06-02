class BookingEmailWorker < BaseEmailWorker

  def self.perform(sending)
    @total_sendings = 0
    @total_recipients = 0
    @targets = 0
    @blacklisted = []
    @formatted = []

    booking = Booking.find(sending.sendable_id)

    methods = ["multiple_booking", "reminder_multiple_booking"]
    if methods.include? sending.method
      self.perform_multiple(booking, sending.method)
    else
      self.perform_single(booking, sending.method)
    end

    @blacklisted.each do |email|
      log = BookingEmailLog.find_or_initialize_by(transmission_id: '', booking_id: booking.id)
      log.assign_attributes(status: 'Lista de Suprimidos', recipient: email, timestamp: Time.now, subject: 'Correo no enviado', progress: 0, details: 'Las direcciones de correos que se reportan como que no existen, tienen errores de formato, marcan como no deseado los correos enviados por AgendaPro o fallan varias veces al intentar entregas, se incluyen en la lista de suprimidos y AgendaPro no les enviará más correos.')
      log.save
    end
    @formatted.each do |email|
      log = BookingEmailLog.find_or_initialize_by(transmission_id: '', booking_id: booking.id)
      log.assign_attributes(status: 'Error de Formato', recipient: email, timestamp: Time.now, subject: 'Correo no enviado', progress: 0, details: 'Las direcciones de correos que se reportan como que no existen, tienen errores de formato, marcan como no deseado los correos enviados por AgendaPro o fallan varias veces al intentar entregas, se incluyen en la lista de suprimidos y AgendaPro no les enviará más correos.')
      log.save
    end

    sending.update(status: 'delivered', sent_date: DateTime.now, total_sendings: @total_sendings, total_recipients: @total_recipients, total_targets: @targets)
  end

  private
    def self.loggable_filter_mails(recipients)
      filtered = []
      recipients.each do |mail|
        if mail.downcase.is_email?
          if EmailBlacklist.find_by_email(mail).nil?
            filtered << mail.downcase
          else
            Rails.logger.info "Email Blacklisted: #{mail}"
            @blacklisted << mail.downcase
          end
        else
          Rails.logger.info "Email Bad Format: #{mail}"
          @formatted << mail.downcase
        end
      end
      filtered
    end

    def self.get_receipients(booking, recipient_type = "", method = "")
      # Filter recipient
      recipients = case recipient_type
      when "client" then booking.client
      when "provider" then NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: booking.service_provider), receptor_type: 2).select(:email).distinct
      when "location" then NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: booking.location), receptor_type: 1).select(:email).distinct
      when "company" then NotificationEmail.where(company: booking.location.company, receptor_type: 0).select(:email).distinct
      else NotificationEmail.none
      end

      # Filter method
      recipients = case method
      when "new_booking" then booking.web_origin ? recipients.where(new_web: true) : recipients.where(new: true)
      when "cancel_booking" then booking.web_origin ? recipients.where(canceled_web: true) : recipients.where(canceled: true)
      when "confirm_booking" then booking.web_origin ? recipients.where(confirmed_web: true) : recipients.where(confirmed: true)
      when "update_booking" then booking.web_origin ? recipients.where(modified_web: true) : recipients.where(modified: true)
      else NotificationEmail.none
      end unless recipient_type == "client"

      # Get emails
      unless recipient_type == "client" && method == "confirm_booking"
        recipient_type == "client" ? [recipients.email] : recipients.pluck(:email)
      else
        []
      end
    end

    def self.horachic?(method, booking)
      methods = ["new_booking", "cancel_booking", "reminder_booking", "update_booking", "multiple_booking"]
      return booking.marketplace_origin && methods.include?(method)
    end

    def self.perform_single(booking, method)
      if booking.send_mail
        @targets += self.get_receipients(booking, "client", method).size
        recipients = loggable_filter_mails(self.get_receipients(booking, "client", method))
        @total_sendings += 1
        @total_recipients += recipients.size
        BookingMailer.delay.send(method, booking, recipients.join(', '), horachic: self.horachic?(method, booking)) if recipients.size > 0
      end

      @targets += self.get_receipients(booking, "provider", method).size
      recipients = loggable_filter_mails(self.get_receipients(booking, "provider", method))
      name = booking.service_provider.public_name
      recipients.in_groups_of(50).each do |group|
        group.compact!
        @total_sendings += 1
        @total_recipients += group.size
        BookingMailer.delay.send(method, booking, group.join(', '), client: false, name: name) if group.size > 0
      end

      @targets += self.get_receipients(booking, "location", method).size
      recipients = loggable_filter_mails(self.get_receipients(booking, "location", method))
      name = booking.location.name
      recipients.in_groups_of(50).each do |group|
        group.compact!
        @total_sendings += 1
        @total_recipients += group.size
        BookingMailer.delay.send(method, booking, group.join(', '), client: false, name: name) if group.size > 0
      end

      @targets += self.get_receipients(booking, "company", method).size
      recipients = loggable_filter_mails(self.get_receipients(booking, "company", method))
      name = booking.location.company.name
      recipients.in_groups_of(50).each do |group|
        group.compact!
        @total_sendings += 1
        @total_recipients += group.size
        BookingMailer.delay.send(method, booking, group.join(', '), client: false, name: name) if group.size > 0
      end
    end

    def self.perform_multiple(booking, method)
      bookings = case method
      when "multiple_booking" then Booking.where(location: booking.location, booking_group: booking.booking_group).order(:start)
      when "reminder_multiple_booking" then Booking.where(location: booking.location, client: booking.client, start: CustomTimezone.from_booking(booking).offset.ago...(96.hours + CustomTimezone.from_booking(booking).offset).from_now).where.not(status: Status.find_by_name("Cancelado")).where('(is_session = false or (is_session = true and is_session_booked = true))').order(:start)
      end
      send_mail = bookings.reduce{ |t, b| t &&= b.send_mail }

      if send_mail
        @targets += [booking.client.email].size
        recipients = loggable_filter_mails([booking.client.email])
        @total_sendings += 1
        @total_recipients += recipients.size
        BookingMailer.delay.send(method, bookings.to_a, recipients.join(', '), horachic: self.horachic?(method, booking)) if recipients.size > 0 and bookings.count > 0
      end

      unless method == "reminder_multiple_booking"
        # Providers
        bookings.map { |b| b.service_provider }.uniq.each do |provider|
          @targets += NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: provider), receptor_type: 2, summary: false).distinct.pluck(:email).size
          recipients = loggable_filter_mails(NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: provider), receptor_type: 2, summary: false).distinct.pluck(:email))
          name = provider.public_name
          recipients.in_groups_of(50).each do |group|
            group.compact!
            @total_sendings += 1
            @total_recipients += group.size
            BookingMailer.delay.send(method, bookings.where(service_provider: provider).to_a, group.join(', '), client: false, name: name) if group.size > 0 and bookings.count > 0
          end
        end

        # Location
        @targets += NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: booking.location), receptor_type: 1, summary: false).distinct.pluck(:email).size
        recipients = loggable_filter_mails(NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: booking.location), receptor_type: 1, summary: false).distinct.pluck(:email))
        name = booking.location.name
        recipients.in_groups_of(50).each do |group|
          group.compact!
          @total_sendings += 1
          @total_recipients += group.size
          BookingMailer.delay.send(method, bookings.to_a, group.join(', '), client: false, name: name) if group.size > 0 and bookings.count > 0
        end

        # Company
        @targets += NotificationEmail.where(company:  booking.location.company, receptor_type: 0, summary: false).distinct.pluck(:email).size
        recipients = loggable_filter_mails(NotificationEmail.where(company:  booking.location.company, receptor_type: 0, summary: false).distinct.pluck(:email))
        name = booking.location.company.name
        recipients.in_groups_of(50).each do |group|
          group.compact!
          @total_sendings += 1
          @total_recipients += group.size
          BookingMailer.delay.send(method, bookings.to_a, group.join(', '), client: false, name: name) if group.size > 0 and bookings.count > 0
        end
      end
    end
end
