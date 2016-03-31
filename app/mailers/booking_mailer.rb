class BookingMailer < Base::CustomMailer
  layout :select_layout

  include ActionView::Helpers::NumberHelper

  def new_booking (book, recipient, options = {})
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}",
      horachic: false
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Nueva Reserva en #{@company.name}"
    attachments["#{book.service.name}-#{@company.name}.ics"] = book.generate_ics.export()
    unless options[:horachic] # layout green
      @url = @company.web_url
      @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    else # layout horachic
      @header = "Nueva reserva recibida exitosamente."
    end

    # view variables
    @book = book
    @company_setting = @company.company_setting
    @client = options[:client]
    @name = options[:name]

    path = options[:horachic] ? "horachic" : "agendapro"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(@book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/#{path}"
      )
  end

  def cancel_booking (book, recipient, options = {})
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}",
      horachic: false
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Reserva Cancelada en #{@company.name}"
    attachments["#{book.service.name}-#{@company.name}.ics"] = book.generate_ics.export()
    unless options[:horachic] # layout green
      @url = @company.web_url
      @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    else # layout horachic
      @header = "Reserva cancelada correctamente."
    end

    # view variables
    @book = book
    @company_setting = @company.company_setting
    @client = options[:client]
    @name = options[:name]

    layout = options[:horachic] ? "horachic" : "green"
    path = options[:horachic] ? "horachic" : "agendapro"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(@book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/#{path}"
      )
  end

  def reminder_booking (book, recipient, options = {})
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}",
      horachic: false
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "#{options[:client] ? 'Confirma' : 'Recuerda'} tu Reserva en #{@company.name}"
    attachments["#{book.service.name}-#{@company.name}.ics"] = book.generate_ics.export()
    unless options[:horachic] # layout green
      @url = @company.web_url
      @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    else # layout horachic
      @header = "Confirma tu reserva en #{@company.name}."
    end

    # view variables
    @book = book
    @company_setting = @company.company_setting
    @client = options[:client]
    @name = options[:name]

    layout = options[:horachic] ? "horachic" : "green"
    path = options[:horachic] ? "horachic" : "agendapro"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(@book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/#{path}"
      )
  end

  def confirm_booking (book, recipient, options = {})
    # defaults
    options = {
      name: "#{book.service_provider.public_name}"
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Reserva Confirmada de #{book.client.first_name} #{book.client.last_name}"
    @url = @company.web_url
    @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")

    # view variables
    @book = book
    @company_setting = @company.company_setting
    @name = options[:name]

    mail(
      from: filter_sender(),
      reply_to: filter_sender(@book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def update_booking (book, recipient, options = {})
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}",
      horachic: false
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Reserva Actualizada en #{@company.name}"
    attachments["#{book.service.name}-#{@company.name}.ics"] = book.generate_ics.export()
    unless options[:horachic] # layout green
      @url = @company.web_url
      @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    else # layout horachic
      @header = "Reserva modificada correctamente."
    end

    # view variables
    @book = book
    @company_setting = @company.company_setting
    @client = options[:client]
    @name = options[:name]
    @old_booking = @book.booking_histories.second

    layout = options[:horachic] ? "horachic" : "green"
    path = options[:horachic] ? "horachic" : "agendapro"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(@book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/#{path}"
      )
  end

  def admin_session_booking (book, recipient, options = {})
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}"
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Nueva Reserva en #{@company.name}"
    @url = @company.web_url
    @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    attachments["#{book.service.name}-#{@company.name}.ics"] = book.generate_ics.export()

    # view variables
    @book = book
    @company_setting = @company.company_setting
    @client = options[:client]
    @name = options[:name]

    mail(
      from: filter_sender(),
      reply_to: filter_sender(@book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def multiple_booking (bookings, recipient, options = {})
    book = bookings.first
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}",
      horachic: false
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Nueva Reserva en #{@company.name}"
    unless options[:horachic] # layout green
      @url = @company.web_url
      @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    else # layout horachic
      @header = "Nueva reserva recibida exitosamente."
    end

    # view variables
    @bookings = bookings
    @company_setting = @company.company_setting
    @client = options[:client]
    @name = options[:name]

    path = options[:horachic] ? "horachic" : "agendapro"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/#{path}"
      )
  end

  def reminder_multiple_booking (bookings, recipient, options = {})
    book = bookings.first
    # defaults
    options = {
      name: "#{book.client.first_name} #{book.client.last_name}",
      horachic: false
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Confirma tus reservas #{@company.name}"
    unless options[:horachic] # layout green
      @url = @company.web_url
      @company.logo.email.url.include?("logo_vacio") ? attacht_logo() : attacht_logo("public#{@company.logo.email.url}")
    else # layout horachic
      @header = "Confirma tus reservas #{@company.name}"
    end

    # view variables
    @bookings = bookings
    @company_setting = @company.company_setting
    @name = options[:name]

    path = options[:horachic] ? "horachic" : "agendapro"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/#{path}"
      )
  end

  #################### Legacy ####################
  def booking_summary (booking_data, booking_summary, today_schedule)
    # => Template
    template_name = 'Booking Summary'
    template_content = []

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :subject => 'Resumen de Reservas',
      :to => [
        {
          :email => booking_data[:to],
          :type => 'to'
        }
      ],
      :global_merge_vars => [
        {
          :name => 'COMPANYNAME',
          :content => booking_data[:company]
        },
        {
          :name => 'URL',
          :content => booking_data[:url]
        },
        {
          :name => 'NAME',
          :content => booking_data[:name]
        },
        {
          :name => 'SUMMARY',
          :content => booking_summary
        },
        {
          :name => 'TODAY',
          :content => today_schedule
        },
        {
          :name => 'DOMAIN',
          :content => booking_data[:domain]
        }
      ],
      :tags => ['booking', 'booking_summary'],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read(booking_data[:logo].to_s))
        }
      ]
    }

    # => Send mail
    send_mail(template_name, template_content, message)
  end

  #Mail de reserva de servicio con sesiones
  def sessions_booking_mail(data)
    # => Template
    template_name = 'Sessions Bookings'
    template_content = []

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => data[:company],
      :subject => 'Nueva Reserva en ' + data[:company],
      :to => [],
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => data[:url]
        },
        {
          :name => 'COMPANYNAME',
          :content => data[:company]
        },
        {
          :name => 'SIGNATURE',
          :content => data[:signature]
        },
        {
          :name => 'DOMAIN',
          :content => data[:domain]
        }
      ],
      :merge_vars => [],
      :tags => ['booking', 'new_booking'],
      :images => [
        {
          :type => data[:type],
          :name => 'LOGO',
          :content => data[:logo]
        }
      ]
    }

    # Notificacion cliente
    if data[:user][:send_mail]
      message[:to] = [{
                :email => data[:user][:email],
                :name => data[:user][:name],
                :type => 'to'
              }]
      message[:merge_vars] = [{
              :rcpt => data[:user][:email],
              :vars => [
                {
                  :name => 'LOCALADDRESS',
                  :content => data[:user][:where]
                },
                {
                  :name => 'LOCATIONPHONE',
                  :content => number_to_phone(data[:user][:phone])
                },
                {
                  :name => 'BOOKINGS',
                  :content => data[:user][:user_table]
                },
                {
                  :name => 'AGENDA',
                  :content => data[:user][:agenda]
                },
                {
                  :name => 'CLIENTNAME',
                  :content => data[:user][:name]
                },
                {
                  :name => 'CLIENT',
                  :content => true
                }
              ]
            }]

      if data[:user][:can_cancel]
        message[:merge_vars][0][:vars] << {
          :name => 'CANCEL',
          :content => data[:user][:cancel]
        }
      end

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Notificacion service provider
    data[:provider][:array].each do |provider|
      message[:to] = [{
                :email => provider[:email],
                :type => 'bcc'
              }]
      message[:merge_vars] = [{
                :rcpt => provider[:email],
                :vars => [
                  {
                    :name => 'CLIENTNAME',
                    :content => data[:provider][:client_name]
                  },
                  {
                    :name => 'SERVICEPROVIDER',
                    :content => provider[:name]
                  },
                  {
                    :name => 'BOOKINGS',
                    :content => provider[:provider_table]
                  }
                ]
              }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Email notificacion local
    data[:locations].each do |location|
      message[:to] = [{
              :email => location[:email],
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => location[:email],
              :vars => [
                {
                  :name => 'CLIENTNAME',
                  :content => location[:client_name]
                },
                {
                  :name => 'SERVICEPROVIDER',
                  :content => location[:name]
                },
                {
                  :name => 'BOOKINGS',
                  :content => location[:location_table]
                }
              ]
            }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Email notificacion company
    data[:companies].each do |company|
      message[:to] = [{
              :email => company[:email],
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => company[:email],
              :vars => [
                {
                  :name => 'CLIENTNAME',
                  :content => company[:client_name]
                },
                {
                  :name => 'SERVICEPROVIDER',
                  :content => company[:name]
                },
                {
                  :name => 'BOOKINGS',
                  :content => company[:company_table]
                }
              ]
            }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end
  end

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end

    def select_layout
      if @header
        "mailers/horachic"
      else
        "mailers/green"
      end
    end
end
