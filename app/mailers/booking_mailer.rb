class BookingMailer < Base::CustomMailer
  layout "mailers/green"

  include ActionView::Helpers::NumberHelper

  def new_booking (book, recipient, options = {})
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}"
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Nueva Reserva en #{@company.name}"
    @url = @company.web_url
    attacht_logo("public#{@company.logo.email.url}" unless @company.logo.email.url.include?("logo_vacio"))
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

  def cancel_booking (book, recipient, options = {})
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}"
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Reserva Cancelada en #{@company.name}"
    @url = @company.web_url
    attacht_logo("public#{@company.logo.email.url}" unless @company.logo.email.url.include?("logo_vacio"))

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

  def reminder_booking (book, recipient, options = {})
    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}"
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "#{options[:client] ? 'Confirma' : 'Recuerda'} tu Reserva en #{@company.name}"
    @url = @company.web_url
    attacht_logo("public#{@company.logo.email.url}" unless @company.logo.email.url.include?("logo_vacio"))
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

  def confirm_booking (book, recipient, options = {})
    # defaults
    options = {
      name: "#{book.service_provider.public_name}"
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Reserva Confirmada de #{book.client.first_name} #{book.client.last_name}"
    @url = @company.web_url
    attacht_logo("public#{@company.logo.email.url}" unless @company.logo.email.url.include?("logo_vacio"))

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
      name: "#{book.client.first_name} #{book.client.last_name}"
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Reserva Actualizada en #{@company.name}"
    @url = @company.web_url
    attacht_logo("public#{@company.logo.email.url}" unless @company.logo.email.url.include?("logo_vacio"))
    attachments["#{book.service.name}-#{@company.name}.ics"] = book.generate_ics.export()

    # view variables
    @book = book
    @company_setting = @company.company_setting
    @client = options[:client]
    @name = options[:name]
    @old_booking = @book.booking_histories.second

    mail(
      from: filter_sender(),
      reply_to: filter_sender(@book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
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
    attacht_logo("public#{@company.logo.email.url}" unless @company.logo.email.url.include?("logo_vacio"))
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

  def new_booking_horachic (book, recipient, options = {})
    layout "mailers/horachic"

    # defaults
    options = {
      client: true,
      name: "#{book.client.first_name} #{book.client.last_name}"
    }.merge(options)

    @company = book.location.company

    # layout variables
    @title = "Nueva Reserva en #{@company.name}"
    @header = "Nueva reserva recibida exitosamente."
    attachments["#{book.service.name}-#{@company.name}.ics"] = book.generate_ics.export()

    # view variables
    @book = book
    @company_setting = @company.company_setting
    @name = options[:name]

    mail(
      from: filter_sender(),
      reply_to: filter_sender(@book.location.email),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/horachic"
      )
  end

  #################### HoraChic ####################
  def cancel_booking_legacy (book_info)
    # => Template
    template_name = 'Cancel Booking'
    template_content = []

    company = book_info.service_provider.company

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => company.name,
      :subject => 'Reserva Cancelada en ' + company.name,
      :to => [],
      :headers => { 'Reply-To' => book_info.location.email },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => book_info.location.get_web_address
        },
        {
          :name => 'COMPANYNAME',
          :content => company.name
        },
        {
          :name => 'CLIENTNAME',
          :content => book_info.client.first_name + ' ' + book_info.client.last_name
        },
        {
          :name => 'SERVICEPROVIDER',
          :content => company.company_setting.provider_preference == 2 ? "" : book_info.service_provider.public_name
        },
        {
          :name => 'SERVICENAME',
          :content => book_info.service.name
        },
        {
          :name => 'BSTART',
          :content => l(book_info.start)
        },
        {
          :name => 'SIGNATURE',
          :content => company.company_setting.signature
        },
        {
          :name => 'DOMAIN',
          :content => company.country.domain
        }
      ],
      :merge_vars => [],
      :tags => ['booking', 'cancel_booking'],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
        }
      ]
    }

    # => Logo empresa
    if !company.logo.email.url.include? "logo_vacio"
      message[:images] = [{
              :type => 'image/png',
              :name => 'LOGO',
              :content => Base64.encode64(File.read('public' + company.logo.email.url.to_s))
            }]
    end

    if !book_info.notes.blank?
      message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
    end

    # Notificacion cliente
    if book_info.send_mail
      message[:to] = [{
              :email => book_info.client.email,
              :name => book_info.client.first_name + ' ' + book_info.client.last_name,
              :type => 'to'
            }]
      mergeVars = {
        :rcpt => book_info.client.email,
        :vars => [
          {
            :name => 'LOCALADDRESS',
            :content => "#{book_info.location.short_address_with_second_address}"
          },
          {
            :name => 'LOCATIONPHONE',
            :content => number_to_phone(book_info.location.phone)
          },
          {
            :name => 'CLIENT',
            :content => true
          }
        ]
      }
      if !book_info.payed_booking.nil?
        mergeVars[:vars] << {
              :name => 'PAYED',
              :content => "true"
            }
      end
      message[:merge_vars] = [mergeVars]

      client_template_name = template_name
      if book_info.marketplace_origin
        client_template_name = 'Cancel Booking - Marketplace'
      end

      # => Send mail
      send_mail(client_template_name, template_content, message)
    end

    # Notificacion service provider
    providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: book_info.service_provider), receptor_type: 2).select(:email).distinct
    if book_info.web_origin
      providers_emails = providers_emails.where(canceled_web: true)
    else
      providers_emails = providers_emails.where(canceled: true)
    end
    providers_emails.each do |provider|
      message[:to] = [{
                :email => provider.email,
                :type => 'bcc'
              }]
      message[:merge_vars] = [{
                :rcpt => provider.email,
                :vars => [
                  {
                    :name => 'COMPANYCOMMENT',
                    :content => book_info.company_comment
                  }
                ]
              }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Email notificacion local
    location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: book_info.location), receptor_type: 1).select(:email).distinct
    if book_info.web_origin
      location_emails = location_emails.where(canceled_web: true)
    else
      location_emails = location_emails.where(canceled: true)
    end
    location_emails.each do |local|
      message[:to] = [{
              :email => local.email,
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => local.email,
              :vars => [
                {
                  :name => 'COMPANYCOMMENT',
                  :content => book_info.company_comment
                }
              ]
            }]
      message[:global_merge_vars][3] = {
            :name => 'SERVICEPROVIDER',
            :content => book_info.location.name
          }

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Email notificacion compañia
    company_emails = NotificationEmail.where(company: company, receptor_type: 0).select(:email).distinct
    if book_info.web_origin
      company_emails = company_emails.where(canceled_web: true)
    else
      company_emails = company_emails.where(canceled: true)
    end
    company_emails.each do |company_emails|
      message[:to] = [{
              :email => company_emails.email,
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => company_emails.email,
              :vars => [
                {
                  :name => 'COMPANYCOMMENT',
                  :content => book_info.company_comment
                }
              ]
            }]
      message[:global_merge_vars][3] = {
            :name => 'SERVICEPROVIDER',
            :content => company.name
          }

      # => Send mail
      send_mail(template_name, template_content, message)
    end
  end
  def book_reminder_mail (book_info)
    # => Template
    template_name = 'Booking Reminder'
    template_content = []

    company = book_info.service_provider.company

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => company.name,
      :subject => 'Confirma tu reserva en ' + company.name,
      :to => [],
      :headers => { 'Reply-To' => book_info.location.email },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => book_info.location.get_web_address
        },
        {
          :name => 'COMPANYNAME',
          :content => company.name
        },
        {
          :name => 'CLIENTNAME',
          :content => book_info.client.first_name + ' ' + book_info.client.last_name
        },
        {
          :name => 'SERVICEPROVIDER',
          :content => company.company_setting.provider_preference == 2 ? "" : book_info.service_provider.public_name
        },
        {
          :name => 'SERVICENAME',
          :content => book_info.service.name
        },
        {
          :name => 'BSTART',
          :content => l(book_info.start)
        },
        {
          :name => 'SIGNATURE',
          :content => company.company_setting.signature
        },
        {
          :name => 'DOMAIN',
          :content => company.country.domain
        }
      ],
      :merge_vars => [],
      :tags => ['booking', 'remind_booking'],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
        },
        {
          :type => 'image/png',
          :name => 'ARROW',
          :content => Base64.encode64(File.read('app/assets/ico/email/flecha_verde.png'))
        }
      ]
    }

    if !book_info.notes.blank?
      message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
    end

    # => Logo empresa
    if !company.logo.email.url.include? "logo_vacio"
      message[:images][0] = {
              :type => 'image/png',
              :name => 'LOGO',
              :content => Base64.encode64(File.read('public' + company.logo.email.url.to_s))
            }
    end

    # Notificacion cliente
    if book_info.send_mail
      message[:to] = [{
              :email => book_info.client.email,
              :name => book_info.client.first_name + ' ' + book_info.client.last_name,
              :type => 'to'
            }]
      message[:merge_vars] = [{
              :rcpt => book_info.client.email,
              :vars => [
                {
                  :name => 'LOCALADDRESS',
                  :content => "#{book_info.location.short_address_with_second_address}"
                },
                {
                  :name => 'LOCATIONPHONE',
                  :content => number_to_phone(book_info.location.phone)
                },
                {
                  :name => 'CONFIRM',
                  :content => confirm_booking_url(:confirmation_code => book_info.confirmation_code)
                },
                {
                  :name => 'CLIENT',
                  :content => true
                }
              ]
            }]

      if company.company_setting.can_edit && book_info.service.online_booking && book_info.service_provider.online_booking
        message[:merge_vars][0][:vars] << {
          :name => 'EDIT',
          :content => book_info.marketplace_origin ? book_info.marketplace_url('edit') : booking_edit_url(:confirmation_code => book_info.confirmation_code)
        }
      end
      if company.company_setting.can_cancel
        message[:merge_vars][0][:vars] << {
          :name => 'CANCEL',
          :content => book_info.marketplace_origin ? book_info.marketplace_url('cancel') : booking_cancel_url(:confirmation_code => book_info.confirmation_code)
        }
      end

      client_template_name = template_name
      if book_info.marketplace_origin
        client_template_name = 'Booking Reminder - Marketplace'
      end

      # => Send mail
      send_mail(client_template_name, template_content, message)
    end

    # New subject
    message[:subject] = 'Recuerda tu reserva en ' + company.name

    # Remove arrow
    message[:images].pop

    # Notificacion service provider
    providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: book_info.service_provider), company_id: Company.where(active: true), receptor_type: 2, summary: false).select(:email).distinct
    providers_emails.each do |provider|
      message[:to] = [{
                :email => provider.email,
                :type => 'bcc'
              }]
      message[:merge_vars] = [{
                :rcpt => provider.email,
                :vars => [
                  {
                    :name => 'COMPANYCOMMENT',
                    :content => book_info.company_comment
                  }
                ]
              }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Email notificacion local
    location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: book_info.location), company_id: Company.where(active: true), receptor_type: 1, summary: false).select(:email).distinct
    location_emails.each do |local|
      message[:to] = [{
              :email => local.email,
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => local.email,
              :vars => [
                {
                  :name => 'COMPANYCOMMENT',
                  :content => book_info.company_comment
                }
              ]
            }]
      message[:global_merge_vars][3] = {
            :name => 'SERVICEPROVIDER',
            :content => book_info.location.name
          }

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Email notificacion compañia
    company_emails = NotificationEmail.where(company_id: Company.where(id: company.id, active: true), receptor_type: 0, summary: false).select(:email).distinct
    company_emails.each do |company_emails|
      message[:to] = [{
              :email => company_emails.email,
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => company_emails.email,
              :vars => [
                {
                  :name => 'COMPANYCOMMENT',
                  :content => book_info.company_comment
                }
              ]
            }]
      message[:global_merge_vars][3] = {
            :name => 'SERVICEPROVIDER',
            :content => company.name
          }

      # => Send mail
      send_mail(template_name, template_content, message)
    end
  end
  def update_booking_legacy (book_info, old_start)
    # => Template
    template_name = 'Update Booking'
    template_content = []

    company = book_info.service_provider.company
    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => book_info.service_provider.company.name,
      :subject => 'Reserva Actualizada en ' + company.name,
      :to => [],
      :headers => { 'Reply-To' => book_info.location.email },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => book_info.location.get_web_address
        },
        {
          :name => 'COMPANYNAME',
          :content => company.name
        },
        {
          :name => 'CLIENTNAME',
          :content => book_info.client.first_name + ' ' + book_info.client.last_name
        },
        {
          :name => 'SERVICEPROVIDER',
          :content => company.company_setting.provider_preference == 2 ? "" : book_info.service_provider.public_name
        },
        {
          :name => 'SERVICENAME',
          :content => book_info.service.name
        },
        {
          :name => 'BSTART',
          :content => l(book_info.start)
        },
        {
          :name => 'SIGNATURE',
          :content => company.company_setting.signature
        },
        {
          :name => 'OLD_START',
          :content => l(old_start)
        },
        {
          :name => 'DOMAIN',
          :content => company.country.domain
        }
      ],
      :merge_vars => [],
      :tags => ['booking', 'edit_booking'],
      :images => [
        {
          :type => 'image/png',
          :name => 'LOGO',
          :content => Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
        }
      ],
      :attachments => [
        {
          :type => 'text/calendar',
          :name => book_info.service.name + ' - ' + company.name + '.ics',
          :content => Base64.encode64(book_info.generate_ics.export())
        }
      ]
    }

    # => Logo empresa
    if !company.logo.email.url.include? "logo_vacio"
      message[:images] = [{
              :type => 'image/png',
              :name => 'LOGO',
              :content => Base64.encode64(File.read('public' + company.logo.email.url.to_s))
            }]
    end

    if !book_info.notes.blank?
      message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
    end

    # Notificacion cliente
    if book_info.send_mail
      message[:to] = [{
              :email => book_info.client.email,
              :name => book_info.client.first_name + ' ' + book_info.client.last_name,
              :type => 'to'
            }]
      message[:merge_vars] = [{
              :rcpt => book_info.client.email,
              :vars => [
                {
                  :name => 'LOCALADDRESS',
                  :content => "#{book_info.location.short_address_with_second_address}"
                },
                {
                  :name => 'LOCATIONPHONE',
                  :content => number_to_phone(book_info.location.phone)
                },
                {
                  :name => 'CLIENT',
                  :content => true
                }
              ]
            }]

      if company.company_setting.can_edit && book_info.service.online_booking && book_info.service_provider.online_booking
        message[:merge_vars][0][:vars] << {
          :name => 'EDIT',
          :content => book_info.marketplace_origin ? book_info.marketplace_url('edit') : booking_edit_url(:confirmation_code => book_info.confirmation_code)
        }
      end
      if company.company_setting.can_cancel
        message[:merge_vars][0][:vars] << {
          :name => 'CANCEL',
          :content => book_info.marketplace_origin ? book_info.marketplace_url('cancel') : booking_cancel_url(:confirmation_code => book_info.confirmation_code)
        }
      end

      client_template_name = template_name
      if book_info.marketplace_origin
        client_template_name = 'Update Booking - Marketplace'
      end

      # => Send mail
      send_mail(client_template_name, template_content, message)
    end

    # Notificacion service provider
    providers_emails = NotificationEmail.where(id: NotificationProvider.select(:notification_email_id).where(service_provider: book_info.service_provider), receptor_type: 2).select(:email).distinct
    if book_info.web_origin
      providers_emails = providers_emails.where(modified_web: true)
    else
      providers_emails = providers_emails.where(modified: true)
    end
    providers_emails.each do |provider|
      message[:to] = [{
                :email => provider.email,
                :type => 'bcc'
              }]
      message[:merge_vars] = [{
                :rcpt => provider.email,
                :vars => [
                  {
                    :name => 'COMPANYCOMMENT',
                    :content => book_info.company_comment
                  }
                ]
              }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Email notificacion local
    location_emails = NotificationEmail.where(id:  NotificationLocation.select(:notification_email_id).where(location: book_info.location), receptor_type: 1).select(:email).distinct
    if book_info.web_origin
      location_emails = location_emails.where(modified_web: true)
    else
      location_emails = location_emails.where(modified: true)
    end
    location_emails.each do |local|
      message[:to] = [{
              :email => local.email,
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => local.email,
              :vars => [
                {
                  :name => 'COMPANYCOMMENT',
                  :content => book_info.company_comment
                }
              ]
            }]
      message[:global_merge_vars][3] = {
            :name => 'SERVICEPROVIDER',
            :content => book_info.location.name
          }

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Email notificacion compañia
    company_emails = NotificationEmail.where(company: company, receptor_type: 0).select(:email).distinct
    if book_info.web_origin
      company_emails = company_emails.where(modified_web: true)
    else
      company_emails = company_emails.where(modified: true)
    end
    company_emails.each do |company_email|
      message[:to] = [{
              :email => company_email.email,
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => company_email.email,
              :vars => [
                {
                  :name => 'COMPANYCOMMENT',
                  :content => book_info.company_comment
                }
              ]
            }]
      message[:global_merge_vars][3] = {
            :name => 'SERVICEPROVIDER',
            :content => company.name
          }

      # => Send mail
      send_mail(template_name, template_content, message)
    end
  end

  #################### Legacy ####################
  def multiple_booking_reminder (data)
    # => Template
    template_name = data[:marketplace] ? 'Confirm Multiple - Marketplace' : 'Multiple Booking Reminder'
    template_content = []

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => data[:company_name],
      :subject => 'Confirma tus reservas en ' + data[:company_name],
      :to => [],
      :headers => { 'Reply-To' => data[:reply_to] },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => data[:url]
        },
        {
          :name => 'COMPANYNAME',
          :content => data[:company_name]
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
                  :name => 'CLIENTNAME',
                  :content => data[:user][:name]
                },
                {
                  :name => 'CLIENT',
                  :content => true
                },
                {
                  :name => 'CANCELALL',
                  :content => data[:user][:cancel_all]
                },
                {
                  :name => 'CONFIRMALL',
                  :content => data[:user][:confirm_all]
                }
              ]
            }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end
  end

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

  def multiple_booking_mail (data)
    # => Template
    template_name = data[:marketplace] ? 'Multiple Bookings - Marketplace' : 'Multiple Booking'
    template_content = []

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => data[:company_name],
      :subject => 'Nueva Reserva en ' + data[:company_name],
      :to => [],
      :headers => { 'Reply-To' => data[:reply_to] },
      :global_merge_vars => [
        {
          :name => 'URL',
          :content => data[:url]
        },
        {
          :name => 'COMPANYNAME',
          :content => data[:company_name]
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
    data[:location][:email].each do |local|
      message[:to] = [{
              :email => local,
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => local,
              :vars => [
                {
                  :name => 'CLIENTNAME',
                  :content => data[:location][:client_name]
                },
                {
                  :name => 'SERVICEPROVIDER',
                  :content => data[:location][:name]
                },
                {
                  :name => 'BOOKINGS',
                  :content => data[:location][:location_table]
                }
              ]
            }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end

    # Notificacion Empresa
    data[:company][:email].each do |company|
      message[:to] = [{
              :email => company,
              :type => 'bcc'
            }]
      message[:merge_vars] = [{
              :rcpt => company,
              :vars => [
                {
                  :name => 'CLIENTNAME',
                  :content => data[:company][:client_name]
                },
                {
                  :name => 'SERVICEPROVIDER',
                  :content => data[:company][:name]
                },
                {
                  :name => 'BOOKINGS',
                  :content => data[:company][:company_table]
                }
              ]
            }]

      # => Send mail
      send_mail(template_name, template_content, message)
    end
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

  #Mail de edición de sesión (depende de si es por admin o no)
  def update_session_booking_mail(booking, is_admin)
  end

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end
end
