class BookingMailer < ActionMailer::Base
  require 'mandrill'
  
  def book_service_mail (book_info)
    require 'base64'

    mandrill = Mandrill::API.new 'HL4ERbuZZO6rrM2nlVjzZg'

    # => Template
    template_name = 'Booking'
    template_content = []

    # => Message
    message = {
      :from_email => 'no-reply@agendapro.cl',
      :from_name => 'AgendaPro',
      :to => [
        {
          :email => book_info.email,
          :name => book_info.last_name + ', ' + book_info.first_name,
          :type => 'to'
        },
        {
        	:email => book_info.service_provider.notification_email,
        	:type => 'to'
        }
      ],
      :global_merge_vars => [
        {
          :name => 'LNAME',
          :content => book_info.last_name
        },
        {
          :name => 'FNAME',
          :content => book_info.first_name
        },
        {
          :name => 'LOCALNAME',
          :content => book_info.location.name
        },
        {
      	  :name => 'SERVICENAME',
      	  :content => book_info.service.name
        },
        {
          :name => 'EMAIL',
          :content => book_info.email
        },
        {
          :name => 'PHONE',
          :content => book_info.phone
        },
        {
          :name => 'BSTART',
          :content => book_info.start
        },
        {
          :name => 'BEND',
          :content => book_info.end
        }
      ],
      :merge_vars => [
      	{
      	  :rcpt => book_info.email,
      	  :vars => [
      	  	{
      	  	  :name => 'RMESSAGE',
      	  	  :content => 'Gracias'
      	  	},
      	  	{
      	  	  :name => 'NAME',
      	  	  :content => book_info.first_name
      	  	},
      	  	{
      	  	  :name => 'MESSAGE',
      	  	  :content => 'Su servicio fue agendado correctamente'
      	  	}
      	  ]
      	},
      	{
      	  :rcpt => book_info.service_provider.notification_email,
      	  :vars => [
      	  	{
      	  	  :name => 'RMESSAGE',
      	  	  :content => 'Estimado,'
      	  	},
      	  	{
      	  	  :name => 'NAME',
      	  	  :content => ''
      	  	},
      	  	{
      	  	  :name => 'MESSAGE',
      	  	  :content => 'Fue agendado un servicio con usted, a continuacion se presentan los detalles'
      	  	}
      	  ]
      	}
      ],
      :tags => ['booking', 'new_booking'],
      :images => [
        {
          :type => 'image/png',
          :name => 'logo.png',
          :content => Base64.encode64(File.read('app/assets/images/home/Logo.png'))
        }
      ]
    }

    if !book_info.notes.empty?
      message[:global_merge_vars] << {:name => 'BNOTES', :content => book_info.notes}
    end

    # => Metadata
    async = false
    send_at = DateTime.now

    # => Send mail
    result = mandrill.messages.send_template template_name, template_content, message, async, send_at

  rescue Mandrill::Error => e
    puts "A mandrill error occurred: #{e.class} - #{e.message}"
    raise
  end
end