class Client < ActiveRecord::Base
  include Filter::Clients

  belongs_to :company

  has_many :client_comments, dependent: :destroy
  has_many :session_bookings, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :client_files, dependent: :destroy
  has_many :float_attributes, dependent: :destroy
  has_many :integer_attributes, dependent: :destroy
  has_many :text_attributes, dependent: :destroy
  has_many :textarea_attributes, dependent: :destroy
  has_many :boolean_attributes, dependent: :destroy
  has_many :date_attributes, dependent: :destroy
  has_many :date_time_attributes, dependent: :destroy
  has_many :file_attributes, dependent: :destroy
  has_many :categoric_attributes, dependent: :destroy
  has_many :product_logs, dependent: :nullify
  has_many :treatment_logs, dependent: :nullify

  scope :from_company, -> (id) { where(company_id: id) if id.present? }

  #Se quitó :identification_uniqueness
  validate :mail_uniqueness, :record_uniqueness, :minimun_info

  after_update :client_notification
  #after_create :create_client_attributes

  def get_birth_date
    if self.birth_day.nil? || self.birth_month.nil?
      return "---"
    elsif self.birth_year.nil?
      return self.birth_day.to_s + "/" + self.birth_month.to_s
    end

    #Unnecesary, just in case we wanted to change birthday format
    birth_date = Date.new(self.birth_year, self.birth_month, self.birth_day)
    return birth_date.strftime("%d/%m/%Y")
  end

  def get_storage_occupation

    used_storage = 0
    used_storage += self.client_files.sum(:size)

  end

  def create_client_attributes

    self.company.custom_attributes.each do |attribute|

      if attribute.datatype == "categoric"
        attribute_category = AttributeCategory.create(attribute_id: attribute.id, category: "Otra")
      end

      case attribute.datatype
      when "float"

        if FloatAttribute.where(attribute_id: attribute.id, client_id: self.id).count == 0
          FloatAttribute.create(attribute_id: attribute.id, client_id: self.id)
        end

      when "integer"

        if IntegerAttribute.where(attribute_id: attribute.id, client_id: self.id).count == 0
          IntegerAttribute.create(attribute_id: attribute.id, client_id: self.id)
        end

      when "text"

        if TextAttribute.where(attribute_id: attribute.id, client_id: self.id).count == 0
          TextAttribute.create(attribute_id: attribute.id, client_id: self.id, value: "")
        end

      when "textarea"

        if TextareaAttribute.where(attribute_id: attribute.id, client_id: self.id).count == 0
          TextareaAttribute.create(attribute_id: attribute.id, client_id: self.id, value: "")
        end

      when "boolean"

        if BooleanAttribute.where(attribute_id: attribute.id, client_id: self.id).count == 0
          BooleanAttribute.create(attribute_id: attribute.id, client_id: self.id)
        end

      when "date"

        if DateAttribute.where(attribute_id: attribute.id, client_id: self.id).count == 0
          DateAttribute.create(attribute_id: attribute.id, client_id: self.id)
        end

      when "datetime"

        if DateTimeAttribute.where(attribute_id: attribute.id, client_id: self.id).count == 0
          DateTimeAttribute.create(attribute_id: attribute.id, client_id: self.id)
        end

      when "file"
        if FileAttribute.where(attribute_id: attribute.id, client_id: self.id).count == 0
          FileAttribute.create(attribute_id: attribute.id, client_id: self.id)
        end
      when "categoric"
        attribute_category = AttributeCategory.create(attribute_id: attribute.id, category: "Otra")
        if CategoricAttribute.where(attribute_id: attribute.id, client_id: client.id).count == 0
          CategoricAttribute.create(attribute_id: attribute.id, client_id: client.id, attribute_category_id: attribute_category.id)
        end
      end

    end

  end

  def get_custom_attributes

    custom_attributes = {}

    self.company.custom_attributes.each do |attribute|

      case attribute.datatype
      when "float"

        float_attribute = FloatAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if !float_attribute.nil?
          custom_attributes[attribute.slug + "_attribute"] = float_attribute.value
        else
          custom_attributes[attribute.slug + "_attribute"] = nil
        end

      when "integer"

        integer_attribute = IntegerAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if !integer_attribute.nil?
          custom_attributes[attribute.slug + "_attribute"] = integer_attribute.value
        else
          custom_attributes[attribute.slug + "_attribute"] = nil
        end

      when "text"

        text_attribute = TextAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if !text_attribute.nil?
          custom_attributes[attribute.slug + "_attribute"] = text_attribute.value
        else
          custom_attributes[attribute.slug + "_attribute"] = ""
        end

      when "textarea"

        textarea_attribute = TextareaAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if !textarea_attribute.nil?
          custom_attributes[attribute.slug + "_attribute"] = textarea_attribute.value
        else
          custom_attributes[attribute.slug + "_attribute"] = ""
        end

      when "boolean"

        boolean_attribute = BooleanAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if !boolean_attribute.nil?
          custom_attributes[attribute.slug + "_attribute"] = boolean_attribute.value
        else
          custom_attributes[attribute.slug + "_attribute"] = false
        end

      when "date"

        date_attribute = DateAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if !date_attribute.nil?
          custom_attributes[attribute.slug + "_attribute"] = date_attribute.value
        else
          custom_attributes[attribute.slug + "_attribute"] = nil
        end

      when "datetime"

        datetime_attribute = DateTimeAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if !datetime_attribute.nil? && !datetime_attribute.value.nil?
          datetime_val = datetime_attribute.value.strftime("%d/%m/%Y %R")
          custom_attributes[attribute.slug + "_attribute"] = datetime_val.split(" ")[0]
          custom_attributes[attribute.slug + "_attribute_hour"] = datetime_val.split(" ")[1].split(":")[0]
          custom_attributes[attribute.slug + "_attribute_minute"] = datetime_val.split(" ")[1].split(":")[1]
        else
          custom_attributes[attribute.slug + "_attribute"] = ""
          custom_attributes[attribute.slug + "_attribute_hour"] = nil
          custom_attributes[attribute.slug + "_attribute_minute"] = nil
        end

      when "categoric"

        categoric_attribute = CategoricAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if !categoric_attribute.nil?
          custom_attributes[attribute.slug + "_attribute"] = categoric_attribute.attribute_category_id
        else
          custom_attributes[attribute.slug + "_attribute"] = nil
        end

      end

    end

    return custom_attributes

  end

  def save_attributes(params)

    if params.blank?
      return
    end

    self.company.custom_attributes.each do |attribute|

      str_sm = attribute.slug + "_attribute"

      if !params.keys.include?(str_sm)
        next
      end

      param_value = params[str_sm]

      case attribute.datatype
      when "float"

        float_attribute = FloatAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if float_attribute.nil?
          float_attribute = FloatAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          float_attribute.value = param_value
          float_attribute.save
        end

      when "integer"

        integer_attribute = IntegerAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if integer_attribute.nil?
          IntegerAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          integer_attribute.value = param_value
          integer_attribute.save
        end

      when "text"

        text_attribute = TextAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if text_attribute.nil?
          TextAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          text_attribute.value = param_value
          text_attribute.save
        end

      when "textarea"

        textarea_attribute = TextareaAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if textarea_attribute.nil?
          TextareaAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          textarea_attribute.value = param_value
          textarea_attribute.save
        end

      when "boolean"
        logger.debug "Boolean: " + param_value
        if param_value == 1 || param_value == "1" || param_value == true
          param_boolean = true
        else
          param_boolean = false
        end

        boolean_attribute = BooleanAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if boolean_attribute.nil?
          BooleanAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_boolean)
        else
          boolean_attribute.value = param_boolean
          boolean_attribute.save
        end

      when "date"

        if !param_value.blank?
          param_value = param_value.gsub('/', '-')
        end

        date_attribute = DateAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if date_attribute.nil?
          DateAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          date_attribute.value = param_value
          date_attribute.save
        end

      when "datetime"

        if !param_value.blank?
          param_value = param_value.gsub('/', '-')
          date_hour = params[attribute.slug + "_attribute_hour"]
          date_minute = params[attribute.slug + "_attribute_minute"]
        end

        complete_datetime = nil
        if !param_value.blank?
          complete_datetime = param_value + " " + date_hour + ":" + date_minute + ":00"
        end

        date_time_attribute = DateTimeAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if date_time_attribute.nil?
          DateTimeAttribute.create(attribute_id: attribute.id, client_id: self.id, value: complete_datetime)
        else
          date_time_attribute.value = complete_datetime
          date_time_attribute.save
        end

      when "file"

        file_attribute = FileAttribute.where(attribute_id: attribute.id, client_id: self.id).first

        if !param_value.blank?

          file_name = attribute.name
          folder_name = attribute.slug
          content_type = param_value.content_type

          file_extension = param_value.original_filename[param_value.original_filename.rindex(".") + 1, param_value.original_filename.length]

          file_description = attribute.description

          full_name = 'companies/' +  self.company_id.to_s + '/clients/' + self.id.to_s + '/' + folder_name + '/' + param_value.original_filename

          s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

          obj = s3_bucket.object(full_name)

          obj.upload_file(param_value.path(), {acl: 'public-read', content_type: content_type})

          client_file = ClientFile.create(client_id: self.id, name: file_name, full_path: full_name, public_url: obj.public_url, size: obj.size, description: file_description)

          if file_attribute.nil?
            FileAttribute.create(attribute_id: attribute.id, client_id: self.id, client_file_id: client_file.id)
          else
            if !file_attribute.client_file.nil?
              file_attribute.client_file.destroy
            end
            file_attribute.client_file_id = client_file.id
            file_attribute.save
          end

        end


      when "categoric"

        categoric_attribute = CategoricAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if categoric_attribute.nil?
          CategoricAttribute.create(attribute_id: attribute.id, client_id: self.id, attribute_category_id: param_value)
        else
          categoric_attribute.attribute_category_id = param_value
          categoric_attribute.save
        end

      end

    end

  end

  def save_attributes_from_import(params)

    if params.blank?
      return
    end

    self.company.custom_attributes.each do |attribute|

      str_sm = attribute.slug
      param_value = params[str_sm]

      case attribute.datatype
      when "float"

        float_attribute = FloatAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if float_attribute.nil?
          float_attribute = FloatAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          float_attribute.value = param_value
          float_attribute.save
        end

      when "integer"

        integer_attribute = IntegerAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if integer_attribute.nil?
          IntegerAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          integer_attribute.value = param_value
          integer_attribute.save
        end

      when "text"

        text_attribute = TextAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if text_attribute.nil?
          TextAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          text_attribute.value = param_value
          text_attribute.save
        end

      when "textarea"

        textarea_attribute = TextareaAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if textarea_attribute.nil?
          TextareaAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          textarea_attribute.value = param_value
          textarea_attribute.save
        end

      when "boolean"

        if param_value == 1 || param_value == "1" || param_value == true
          param_boolean = true
        else
          param_boolean = false
        end

        boolean_attribute = BooleanAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if boolean_attribute.nil?
          BooleanAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_boolean)
        else
          boolean_attribute.value = param_boolean
          boolean_attribute.save
        end

      when "date"

        if !param_value.blank?
          param_value = param_value.gsub('/', '-')
        end

        date_attribute = DateAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if date_attribute.nil?
          DateAttribute.create(attribute_id: attribute.id, client_id: self.id, value: param_value)
        else
          date_attribute.value = param_value
          date_attribute.save
        end

      when "datetime"

        complete_datetime = nil

        if !param_value.blank?
          param_value = param_value.gsub('/', '-')
          complete_datetime = param_value
        end

        date_time_attribute = DateTimeAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if date_time_attribute.nil?
          DateTimeAttribute.create(attribute_id: attribute.id, client_id: self.id, value: complete_datetime)
        else
          date_time_attribute.value = complete_datetime
          date_time_attribute.save
        end

      when "categoric"

        categoric_attribute = CategoricAttribute.where(attribute_id: attribute.id, client_id: self.id).first
        if categoric_attribute.nil?
          CategoricAttribute.create(attribute_id: attribute.id, client_id: self.id, attribute_category_id: param_value)
        else
          categoric_attribute.attribute_category_id = param_value
          categoric_attribute.save
        end

      end

    end

  end

  def self.bookings_reminder

    canceled_status = Status.find_by_name("Cancelado")
    bookings = Array.new
    #Send all services from same client (each company has diferent clients)
    Client.where(id: Booking.where(:start => CustomTimezone.first_timezone.offset.ago...(96.hours + CustomTimezone.last_timezone.offset).from_now).where.not(:status_id => canceled_status.id).pluck(:client_id)).where.not(email: [nil, ""]).each do |client|

      #Send a reminder for each location
      client.company.locations.each do |location|

        bookings = Array.new
        single_booking = Booking.new

        timezone = CustomTimezone.from_company(client.company)

        potential_bookings = client.bookings.where(:start => timezone.offset.ago...(96.hours + timezone.offset).from_now).where.not(:status_id => canceled_status.id).where(:location_id => location.id)

        potential_bookings.each do |booking|

          booking_confirmation_time = booking.location.company.company_setting.booking_confirmation_time

          if ((booking_confirmation_time.days + timezone.offset).from_now..(booking_confirmation_time.days + 1.days + timezone.offset).from_now).cover?(booking.start) && booking.send_mail

            if booking.is_session
              if booking.is_session_booked and booking.user_session_confirmed
                bookings << booking
              end
            else
              bookings << booking
            end

            single_booking = booking

          end

        end

        if bookings.count > 0
          if bookings.count > 1

            #Set an id to identify bookings that were sent in this reminder

            last_reminder_group = 0

            last_reminder_booking = Booking.where(:location_id => location.id).where.not(reminder_group: nil).order('reminder_group asc').last

            # If there is one that's not null, then get the last one
            if !last_reminder_booking.nil?
              last_reminder_group = last_reminder_booking.reminder_group + 1
            end

            bookings.each do |b|
              puts "Booking " + b.id.to_s + " will be sent with reminder_group: " + last_reminder_group.to_s
              b.reminder_group = last_reminder_group
              b.save
            end

            #Send multiple bookings reminder
            bookings.first.sendings.build(method: 'reminder_multiple_booking').save
          else
            #Send regular reminder
            puts "Booking " + single_booking.id.to_s + " will be sent alone."
            single_booking.sendings.build(method: 'reminder_booking').save
          end
        end

      end

    end

  end

  def client_notification
    if changed_attributes['email']
      if self.email
        valid = false
        atpos = self.email.index("@")
        dotpos = self.email.rindex(".")
        if atpos && dotpos
          if (atpos < 1) || (dotpos < atpos+2) || (dotpos+2 >= self.email.length)
            valid = false
          end
          valid = true
        end
        if !valid
          timezone = CustomTimezone.from_company(self.company)
          Booking.where('bookings.start >= ?', Time.now + timezone.offset).where(client_id: self.id).each do |booking|
            if booking.send_mail
              booking.send_mail = false
              booking.save
            end
          end
        end
      end
    end
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def valid_email
    if self.email
      atpos = self.email.index("@")
      dotpos = self.email.rindex(".")
      if atpos && dotpos
        if (atpos < 1) || (dotpos < atpos+2) || (dotpos+2 >= self.email.length)
          return false
        end
        return true
      end
      return false
    end
    return false
  end

  def mail_uniqueness
    if self.email.nil? || self.email == ""
      return
    end
    Client.where(company_id: self.company_id, email: self.email).each do |client|
      if self.email && self.email != "" && client != self && client.email != "" && self.email == client.email
        errors.add(:base, "No se pueden crear dos clientes con el mismo email.")
      end
    end
  end

  def record_uniqueness
    if self.record.nil? || self.record == ""
      return
    end
    Client.where(company_id: self.company_id, record: self.record).each do |client|
      if self.record && self.record != "" && client != self && client.record != "" && self.record == client.record
        errors.add(:base, "No se pueden crear dos clientes con el mismo número de ficha.")
      end
    end
  end

  def identification_uniqueness
    if self.identification_number.nil? || self.identification_number == ""
      return
    end
    Client.where(company_id: self.company_id, identification_number: self.identification_number).each do |client|
      if self.identification_number && self.identification_number != "" && client != self && client.identification_number != "" && self.identification_number == client.identification_number
        errors.add(:base, "No se pueden crear dos clientes con el mismo Número de Identificación.")
      end
    end
  end

  def minimun_info
    if self.first_name.blank?
      errors.add(:base, "El cliente debe tener un nombre.")
    end
    if self.last_name.blank? && self.email.blank? && self.phone.blank?
      errors.add(:base, "El cliente debe contener, por lo menos, un apellido, una dirección email o un teléfono.")
    end
  end

  def self.custom_filter(clients, custom_filter)

    if custom_filter.nil?

      return clients

    else

      #Loop through each kind of filters

      #Loop for numeric filters
      custom_filter.numeric_custom_filters.each do |numeric_filter|

        attribute = numeric_filter.attribute

        numeric_attribute = nil

        if attribute.datatype == "integer"
          numeric_attribute = IntegerAttribute.where(attribute_id: attribute.id)
        else
          numeric_attribute = FloatAttribute.where(attribute_id: attribute.id)
        end

        if numeric_filter.option == "equals"
          clients = clients.where(id: numeric_attribute.where(value: numeric_filter.value1).pluck(:client_id))
        elsif numeric_filter.option == "greater"
          clients = clients.where(id: numeric_attribute.where('value > ?', numeric_filter.value1).pluck(:client_id))
        elsif numeric_filter.option == "greater_equal"
          clients = clients.where(id: numeric_attribute.where('value >= ?', numeric_filter.value1).pluck(:client_id))
        elsif numeric_filter.option == "lower"
          clients = clients.where(id: numeric_attribute.where('value < ?', numeric_filter.value1).pluck(:client_id))
        elsif numeric_filter.option == "lower_equal"
          clients = clients.where(id: numeric_attribute.where('value <= ?', numeric_filter.value1).pluck(:client_id))
        elsif numeric_filter.option == "between"
          #Check for exclusive options
          if numeric_filter.exclusive1 && numeric_filter.exclusive2
            clients = clients.where(id: numeric_attribute.where('value > ? and value < ?', numeric_filter.value1, numeric_filter.value2).pluck(:client_id))
          elsif numeric_filter.exclusive1 && !numeric_filter.exclusive2
            clients = clients.where(id: numeric_attribute.where('value > ? and value <= ?', numeric_filter.value1, numeric_filter.value2).pluck(:client_id))
          elsif !numeric_filter.exclusive1 && numeric_filter.exclusive2
            clients = clients.where(id: numeric_attribute.where('value >= ? and value < ?', numeric_filter.value1, numeric_filter.value2).pluck(:client_id))
          else
            clients = clients.where(id: numeric_attribute.where('value => ? and value <= ?', numeric_filter.value1, numeric_filter.value2).pluck(:client_id))
          end
        elsif numeric_filter.option == "out"
          #Check for exclusive optionss
          if numeric_filter.exclusive1 && numeric_filter.exclusive2
            clients = clients.where(id: numeric_attribute.where('value < ? and value > ?', numeric_filter.value1, numeric_filter.value2).pluck(:client_id))
          elsif numeric_filter.exclusive1 && !numeric_filter.exclusive2
            clients = clients.where(id: numeric_attribute.where('value < ? and value >= ?', numeric_filter.value1, numeric_filter.value2).pluck(:client_id))
          elsif !numeric_filter.exclusive1 && numeric_filter.exclusive2
            clients = clients.where(id: numeric_attribute.where('value <= ? and value > ?', numeric_filter.value1, numeric_filter.value2).pluck(:client_id))
          else
            clients = clients.where(id: numeric_attribute.where('value <= ? and value >= ?', numeric_filter.value1, numeric_filter.value2).pluck(:client_id))
          end
        end

      end

      #Loop for date filters
      custom_filter.date_custom_filters.each do |date_filter|

        attribute = date_filter.attribute

        date_attribute = nil

        if attribute.datatype == "date"
          date_attribute = DateAttribute.where(attribute_id: attribute.id)
        else
          date_attribute = DateTimeAttribute.where(attribute_id: attribute.id)
        end


        if date_filter.option == "equals"
          clients = clients.where(id: date_attribute.where(value: date_filter.date1).pluck(:client_id))
        elsif date_filter.option == "greater"
          clients = clients.where(id: date_attribute.where('value > ?', date_filter.date1).pluck(:client_id))
        elsif date_filter.option == "greater_equal"
          clients = clients.where(id: date_attribute.where('value >= ?', date_filter.date1).pluck(:client_id))
        elsif date_filter.option == "lower"
          clients = clients.where(id: date_attribute.where('value < ?', date_filter.date1).pluck(:client_id))
        elsif date_filter.option == "lower_equal"
          clients = clients.where(id: date_attribute.where('value <= ?', date_filter.date1).pluck(:client_id))
        elsif date_filter.option == "between"
          #Check for exclusive options
          if date_filter.exclusive1 && date_filter.exclusive2
            clients = clients.where(id: date_attribute.where('value > ? and value < ?', date_filter.date1, date_filter.date2).pluck(:client_id))
          elsif date_filter.exclusive1 && !date_filter.exclusive2
            clients = clients.where(id: date_attribute.where('value > ? and value <= ?', date_filter.date1, date_filter.date2).pluck(:client_id))
          elsif !date_filter.exclusive1 && date_filter.exclusive2
            clients = clients.where(id: date_attribute.where('value >= ? and value < ?', date_filter.date1, date_filter.date2).pluck(:client_id))
          else
            clients = clients.where(id: date_attribute.where('value => ? and value <= ?', date_filter.date1, date_filter.date2).pluck(:client_id))
          end
        elsif date_filter.option == "out"
          #Check for exclusive optionss
          if date_filter.exclusive1 && date_filter.exclusive2
            clients = clients.where(id: date_attribute.where('value < ? and value > ?', date_filter.date1, date_filter.date2).pluck(:client_id))
          elsif date_filter.exclusive1 && !date_filter.exclusive2
            clients = clients.where(id: date_attribute.where('value < ? and value >= ?', date_filter.date1, date_filter.date2).pluck(:client_id))
          elsif !date_filter.exclusive1 && date_filter.exclusive2
            clients = clients.where(id: date_attribute.where('value <= ? and value > ?', date_filter.date1, date_filter.date2).pluck(:client_id))
          else
            clients = clients.where(id: date_attribute.where('value <= ? and value >= ?', date_filter.date1, date_filter.date2).pluck(:client_id))
          end
        end


      end

      #Loop for boolean filters
      custom_filter.boolean_custom_filters.each do |boolean_filter|

        attribute = boolean_filter.attribute
        boolean_attribute = BooleanAttribute.where(attribute_id: attribute.id)

        clients = clients.where(id: boolean_attribute.where(value: boolean_filter.option).pluck(:client_id))

      end

      #Loop for categoric filters
      custom_filter.categoric_custom_filters.each do |categoric_filter|

        attribute = categoric_filter.attribute
        categoric_attribute = CategoricAttribute.where(attribute_id: attribute.id)

        clients = clients.where(id: categoric_attribute.where(attribute_category_id: categoric_filter.categories_ids.split(",")).pluck(:client_id))

      end

      #Loop for text filters
      custom_filter.text_custom_filters.each do |text_filter|

        attribute = text_filter.attribute

        text_attribute = nil
        if attribute.datatype == "text"
          text_attribute = TextAttribute.where(attribute_id: attribute.id)
        else
          text_attribute = TextareaAttribute.where(attribute_id: attribute.id)
        end

        clients = clients.where(id: text_attribute.where('value like ?', '%' + text_filter.text + '%').pluck(:client_id))

      end

      return clients

    end

  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

  def self.export_csv(company_id, clients)

    csv_header = ["E-mail","Nombre","Apellido",(I18n.t('ci')).capitalize,"Teléfono","Dirección","Comuna","Fecha Nacimiento","Edad","Género","Fecha Creación"]
    company = Company.find(company_id)
    attributes = company.custom_attributes.joins(:attribute_group).order('attribute_groups.order asc').order('attributes.order asc').order('name asc')
    attributes.each do |attribute|
      if attribute.datatype != "file"
        if attribute.datatype != "categoric" || (attribute.datatype == "categoric" && !attribute.attribute_categories.nil? && attribute.attribute_categories.count > 0)
            csv_header << attribute.name
        end
      end
    end 

    client_lines = []

    clients.each do |client|

      client_birth = ""
      if !client.birth_day.nil? && !client.birth_month.nil? && !client.birth_year.nil?
        client_birth = client.birth_day.to_s + "/" + client.birth_month.to_s + "/" + client.birth_year.to_s
      end

      client_line = [client.email.to_s, client.first_name.to_s, client.last_name.to_s, client.identification_number.to_s, client.phone.to_s, client.address.to_s, client.district.to_s, client_birth, client.age.to_s]

      if client.gender == 1
        client_line << "Femenino"
      elsif client.gender == 2
        client_line << "Masculino"
      else
        client_line << ""
      end 
      client_line << client.created_at.strftime("%d/%m/%Y %R")

      attributes.each do |attribute|
        if attribute.datatype != "file"
          if attribute.datatype == "float"
            float_attribute = FloatAttribute.where(attribute_id: attribute.id, client_id: client.id).first
            float_attribute_value = ""
            if !float_attribute.nil? && !float_attribute.value.nil?
              float_attribute_value = float_attribute.value
            end
              client_line << float_attribute_value.to_s
          elsif attribute.datatype == "integer"
            integer_attribute = IntegerAttribute.where(attribute_id: attribute.id, client_id: client.id).first
            integer_attribute_value = ""
            if !integer_attribute.nil? && !integer_attribute.value.nil?
              integer_attribute_value = integer_attribute.value
            end
            client_line << integer_attribute_value.to_s
          elsif attribute.datatype == "text"
            text_attribute = TextAttribute.where(attribute_id: attribute.id, client_id: client.id).first
            text_attribute_value = ""
            if !text_attribute.nil? && !text_attribute.value.nil?
              text_attribute_value = text_attribute.value
            end
            client_line << text_attribute_value.to_s
          elsif attribute.datatype == "textarea"
            textarea_attribute = TextareaAttribute.where(attribute_id: attribute.id, client_id: client.id).first
            textarea_attribute_value = ""
            if !textarea_attribute.nil? && !textarea_attribute.value.nil?
              textarea_attribute_value = textarea_attribute.value
            end
            client_line << textarea_attribute_value.to_s
          elsif attribute.datatype == "boolean"
            boolean_attribute = BooleanAttribute.where(attribute_id: attribute.id, client_id: client.id).first
            boolean_attribute_value = ""
            if !boolean_attribute.nil? && !boolean_attribute.value.nil?
              if boolean_attribute.value == true
                boolean_attribute_value = "Sí"
              else
                boolean_attribute_value = "No"
              end
            end
            client_line << boolean_attribute_value.to_s
          elsif attribute.datatype == "date"
            date_attribute = DateAttribute.where(attribute_id: attribute.id, client_id: client.id).first
            date_attribute_value = ""
            if !date_attribute.nil? && !date_attribute.value.nil?
              date_attribute_value = date_attribute.value.strftime('%d/%m/%Y')
            end
            client_line << date_attribute_value.to_s
          elsif attribute.datatype == "datetime"
            date_time_attribute = DateTimeAttribute.where(attribute_id: attribute.id, client_id: client.id).first
            date_time_attribute_date = ""
            date_time_attribute_hour = "00"
            date_time_attribute_minute = "00"
            if !date_time_attribute.nil? && !date_time_attribute.value.nil?
              date_time_attribute_value = date_time_attribute.value.strftime("%d/%m/%Y %R")
            end
            client_line << date_time_attribute_value.to_s
          elsif attribute.datatype == "categoric" && !attribute.attribute_categories.nil? && attribute.attribute_categories.count > 0
            categoric_attribute = CategoricAttribute.where(attribute_id: attribute.id, client_id: client.id).first
            category_value = ""
            if !categoric_attribute.attribute_category.nil?
              category_value = categoric_attribute.attribute_category.category
            end
            client_line << category_value.to_s
          end
        end
      end

      client_lines << client_line

    end

    csv_string = CSV.generate() do |csv|
      csv << csv_header
      client_lines.each do |line|
        csv << line
      end
    end


  end

  def self.import(file, company_id)
    allowed_attributes = ["email", "first_name", "last_name", "identification_number", "phone", "address", "district", "city", "age", "gender", "birth_day", "birth_month", "birth_year", "record", "second_phone"]

    spreadsheet = open_spreadsheet(file)

    company = Company.find(company_id)

    if !spreadsheet.nil?
      header = spreadsheet.row(1)
      logger.debug "Header: " + header.inspect
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        if row["email"].present?
          row["email"] = row["email"].to_s
        end

        if row["first_name"].present?
          row["first_name"] = row["first_name"].to_s
        end

        if row["last_name"].present?
          row["last_name"] = row["last_name"].to_s
        end

        if row["phone"].present?
          row["phone"] = row["phone"].to_s.chomp('.0')
        end

        if row["address"].present?
          row["address"] = row["address"].to_s
        end

        if row["district"].present?
          row["district"] = row["district"].to_s
        end

        if row["city"].present?
          row["city"] = row["city"].to_s
        end

        if row["age"].present?
          row["age"] = row["age"].to_i
        end

        if row["gender"].present?
          row["gender"] = row["gender"].to_i
        else
          row["gender"] = 0
        end

        if row["birth_day"].present?
          row["birth_day"] = row["birth_day"].to_i
        end

        if row["birth_month"].present?
          row["birth_month"] = row["birth_month"].to_i
        end

        if row["birth_year"].present?
          row["birth_year"] = row["birth_year"].to_i
        end

        if row["record"].present?
          row["record"] = row["record"].to_s.chomp('.0')
        end

        if row["second_phone"].present?
          row["second_phone"] = row["second_phone"].to_s.chomp('.0')
        end

        if row["identification_number"].present?
          row["identification_number"] = row["identification_number"].to_s.chomp('.0')
        end

        custom_params = Hash.new
        #Check for custom attributes
        company.custom_attributes.each do |attribute|

          case attribute.datatype
          when "float"
            if row[attribute.slug].present?
              custom_params[attribute.slug] = row[attribute.slug].to_f
            else
              custom_params[attribute.slug] = nil
            end
          when "integer"
            if row[attribute.slug].present?
              custom_params[attribute.slug] = row[attribute.slug].to_i
            else
              custom_params[attribute.slug] = nil
            end
          when "boolean"
            if row[attribute.slug].present?
              if row[attribute.slug].downcase == "sí" || row[attribute.slug].downcase == "si"
                custom_params[attribute.slug] = true
              elsif row[attribute.slug] == "1"
                custom_params[attribute.slug] = true
              elsif row[attribute.slug].downcase == "no"
                custom_params[attribute.slug] = false
              elsif row[attribute.slug].downcase == "0"
                custom_params[attribute.slug] = false
              else
                custom_params[attribute.slug] = false
              end
            else
              custom_params[attribute.slug] = nil
            end
          when "text"
            if row[attribute.slug].present?
              custom_params[attribute.slug] = row[attribute.slug].to_s.chomp('.0').strip
            else
              custom_params[attribute.slug] = ""
            end
          when "textarea"
            if row[attribute.slug].present?
              custom_params[attribute.slug] = row[attribute.slug].to_s.chomp('.0').strip
            else
              custom_params[attribute.slug] = ""
            end
          when "date"
            if row[attribute.slug].present?
              custom_params[attribute.slug] = row[attribute.slug].to_date rescue nil
            else
              custom_params[attribute.slug] = nil
            end
          when "datetime"
            if row[attribute.slug].present?
              custom_params[attribute.slug] = row[attribute.slug].to_datetime rescue nil
            else
              custom_params[attribute.slug] = nil
            end
          when "categoric"
            cat_str = row[attribute.slug].to_s.chomp('.0').strip
            cat_id = attribute.check_categories(cat_str)
            custom_params[attribute.slug] = cat_id
          end

        end

        if row["identification_number"].present? && Client.where(identification_number: row["identification_number"], company_id: company_id).count > 0
          client = Client.where(identification_number: row["identification_number"], company_id: company_id).first
        elsif row["email"].present? && Client.where(email: row["email"], company_id: company_id).count > 0
          client = Client.where(email: row["email"], company_id: company_id).first
        elsif row["first_name"].present? && row["last_name"].present? && Client.where(first_name: row["first_name"], last_name: row["last_name"], company_id: company_id).count > 0
          client = Client.where(first_name: row["first_name"], last_name: row["last_name"], company_id: company_id).first
        else
          client = Client.new
        end

        client.attributes = row.to_hash.select { |k,v| allowed_attributes.include? k }
        if company_id
          client.company_id = company_id
        end
        if client.save
          client.save_attributes_from_import(custom_params)
        else
          logger.debug "Errors: "
          logger.debug client.errors.inspect
        end
      end
      message = "Clientes importados exitosamente."
    else
      message = "Error en el archivo de importación, archivo inválido o lista vacía."
    end
  end

  # def self.open_spreadsheet(file)
  #   case File.extname(file.original_filename)
  #   when ".csv" then Roo::Csv.new(file.path, file_warning: :ignore)
  #   when ".xls" then Roo::Excel.new(file.path, file_warning: :ignore)
  #   when ".xlsx" then Roo::Excelx.new(file.path, file_warning: :ignore)
  #   end
  # end

  def self.open_spreadsheet(file)
    file_name = file.original_filename
    file_path = file.path
    begin
      case File.extname(file_name)
      when ".csv"
        # Try to identify separator type
        # Take a wild guess by column count (totally improvable)
        # Accept , ; \t
        # ,
        sheet = Roo::CSV.new(file_path, file_warning: :ignore, csv_options: {col_sep: ","})

        arr = sheet.row(1)
        if arr.length > 2
          if arr[0] == "email" && arr[1] == "first_name" && arr[2] == "last_name"
            return sheet
          end
        end

        # ;
        sheet = Roo::CSV.new(file_path, file_warning: :ignore, csv_options: {col_sep: ";"})

        arr = sheet.row(1)
        if arr.length > 2
          if arr[0] == "email" && arr[1] == "first_name" && arr[2] == "last_name"
            return sheet
          end
        end

        # \t
        sheet = Roo::CSV.new(file_path, file_warning: :ignore, csv_options: {col_sep: "\t"})

        arr = sheet.row(1)
        if arr.length > 2
          if arr[0] == "email" && arr[1] == "first_name" && arr[2] == "last_name"
            return sheet
          end
        end

        return nil

      when ".xlsx"
        Roo::Excelx.new(file_path, file_warning: :ignore)
      when ".xlsm"
        Roo::Excelx.new(file_path, file_warning: :ignore)
      when ".ods"
        Roo::OpenOffice.new(file_path, file_warning: :ignore)
      when ".xls"
        begin
          Roo::Excel.new(file_path, file_warning: :ignore)
        rescue
          Roo::Excel2003XML.new(file_path, file_warning: :ignore)
        end
      when ".xml"
        Roo::Excel2003XML.new(file_path, file_warning: :ignore)
      end
    rescue
      return nil
    end
  end

  def self.test_write(input)
    book = Spreadsheet::Workbook.new
    write_sheet = book.create_worksheet
    row_num = 0
    input.each do |row|
      write_sheet.row(row_num).replace row
      row_num +=1
    end
    book.write "/home/zuru/AgendaPro/roo_test/to.xls"
  end

  def self.filter(company_id, params)
    default_options = {
      search: "",
      attendance: nil
    }
    options = default_options.merge(params.except(:utf8, :action, :controller, :locale).symbolize_keys)
    Filter::Clients.filter(company_id, options)
  end

  def self.filtered(company_id, params)
    # Client.includes(bookings: [:location, :service_provider, :service, :status]).from_company(146).where("booking.location_id" => 179)
    search( params[:search], current_user.company_id )
    filter_gender( params[:gender] )
    filter_birthdate( params[:birth_from], params[:birth_to] )

    filter_location( params[:locations], attendance )
    filter_provider( params[:providers], attendance )
    filter_service( params[:services], attendance )
    filter_status( params[:statuses] )
    filter_range( params[:range_from], params[:range_to], attendance )
  end

end
