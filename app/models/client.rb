class Client < ActiveRecord::Base
  belongs_to :company

  has_many :client_comments, dependent: :destroy
  has_many :session_bookings, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :payments, dependent: :destroy

  validate :mail_uniqueness, :identification_uniqueness, :record_uniqueness, :minimun_info

  after_update :client_notification

  def self.bookings_reminder

    canceled_status = Status.find_by_name("Cancelado")

    #Send all services from same client (each company has diferent clients)
    Client.where(id: Booking.where(:start => eval(ENV["TIME_ZONE_OFFSET"]).ago...(96.hours - eval(ENV["TIME_ZONE_OFFSET"])).from_now).where.not(:status_id => canceled_status.id).pluck(:client_id)).each do |client|

      #Send a reminder for each location
      client.company.locations.each do |location|

        potential_bookings = client.bookings.where(:start => eval(ENV["TIME_ZONE_OFFSET"]).ago...(96.hours - eval(ENV["TIME_ZONE_OFFSET"])).from_now).where.not(:status_id => canceled_status.id).where(:location_id => location.id)

        potential_bookings.each do |booking|

          booking_confirmation_time = booking.location.company.company_setting.booking_confirmation_time

          if ((booking_confirmation_time.days - eval(ENV["TIME_ZONE_OFFSET"])).from_now..(booking_confirmation_time.days + 1.days - eval(ENV["TIME_ZONE_OFFSET"])).from_now).cover?(booking.start) && booking.send_mail

            if booking.is_session
              if booking.is_session_booked and booking.user_session_confirmed
                bookings << booking
              end
            else
              bookings << booking
            end

          end

        end

        if bookings.count > 0
          if bookings.count > 1
            #Send multiple bookings reminder
            send_multiple_reminder(bookings)
          else
            #Send regular reminder
            BookingMailer.book_reminder_mail(booking)
          end
        end

      end

    end

  end


  def self.send_multiple_reminder(bookings)

    helper = Rails.application.routes.url_helpers
    @data = {}

    # GENERAL
      @data[:company_name] = bookings[0].location.company.name
      @data[:reply_to] = bookings[0].location.email
      @data[:url] = bookings[0].location.company.web_address
      @data[:signature] = bookings[0].location.company.company_setting.signature
      @data[:domain] = bookings[0].location.company.country.domain
      @data[:type] = 'image/png'
      if bookings[0].location.company.logo.email.url.include? "logo_vacio"
        @data[:logo] = Base64.encode64(File.read('app/assets/images/logos/logodoble2.png'))
      else
        @data[:logo] = Base64.encode64(File.read('public' + bookings[0].location.company.logo.email.url))
      end

    # USER
      @user = {}
      @user[:where] = bookings[0].location.address + ', ' + bookings[0].location.district.name
      @user[:phone] = bookings[0].location.phone
      @user[:name] = bookings[0].client.first_name
      @user[:send_mail] = bookings[bookings.length - 1].send_mail
      @user[:email] = bookings[0].client.email
      @user[:cancel_all] = helper.cancel_all_booking_url(:confirmation_code => bookings[0].confirmation_code)
      @user[:confirm_all] = helper.confirm_all_bookings_url(:confirmation_code => bookings[0].confirmation_code)

      @user_table = ''
      bookings.each do |book|
        @user_table += '<tr style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;">' +
            '<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + book.service.name + '</td>' +
            '<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + I18n.l(book.start) + '</td>' +
            '<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + book.service_provider.public_name + '</td>' +
            '<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' + if book.notes.blank? then '' else book.notes end + '</td>' +
            '<td style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding-top:8px;padding-bottom:8px;padding-right:8px;padding-left:8px;line-height:1.42857143;vertical-align:top;border-top-width:1px;border-top-style:solid;border-top-color:#ddd;">' +
              '<a class="btn btn-xs btn-orange" target="_blank" href="' + helper.booking_edit_url(:confirmation_code => book.confirmation_code) + '" style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;text-decoration:none;display:inline-block;margin-bottom:5px;font-weight:normal;text-align:center;white-space:nowrap;vertical-align:middle;-ms-touch-action:manipulation;touch-action:manipulation;cursor:pointer;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;background-image:none;border-width:1px;border-style:solid;padding-top:1px;padding-bottom:1px;padding-right:5px;padding-left:5px;font-size:12px;line-height:1.5;border-radius:3px;color:#ffffff;background-color:#fd9610;border-color:#db7400; width: 90%;">Editar</a>' +
              '<a class="btn btn-xs btn-red" target="_blank" href="' + helper.booking_cancel_url(:confirmation_code => book.confirmation_code) + '" style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;text-decoration:none;display:inline-block;margin-bottom:5px;font-weight:normal;text-align:center;white-space:nowrap;vertical-align:middle;-ms-touch-action:manipulation;touch-action:manipulation;cursor:pointer;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;background-image:none;border-width:1px;border-style:solid;padding-top:1px;padding-bottom:1px;padding-right:5px;padding-left:5px;font-size:12px;line-height:1.5;border-radius:3px;color:#ffffff;background-color:#fd633f;border-color:#e55938; width: 90%;">Cancelar</a>' +
              '<a class="btn btn-xs btn-red" target="_blank" href="' + helper.confirm_booking_url(:confirmation_code => book.confirmation_code) + '" style="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;text-decoration:none;display:inline-block;margin-bottom:5px;font-weight:normal;text-align:center;white-space:nowrap;vertical-align:middle;-ms-touch-action:manipulation;touch-action:manipulation;cursor:pointer;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;background-image:none;border-width:1px;border-style:solid;padding-top:1px;padding-bottom:1px;padding-right:5px;padding-left:5px;font-size:12px;line-height:1.5;border-radius:3px;color:#ffffff;background-color:#0f91cf;border-color:#0b587b; width: 90%;">Confirmar</a>' +
            '</td>' +
          '</tr>'
      end

      @user[:user_table] = @user_table

      @data[:user] = @user

      BookingMailer.multiple_booking_reminder(@data)

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
          Booking.where('bookings.start >= ?', Time.now - eval(ENV["TIME_ZONE_OFFSET"])).where(client_id: self.id).each do |booking|
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
        errors.add(:base, "No se pueden crear dos clientes con el mismo RUT.")
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

  def self.search(search, company_id)
    if search
      search_raw = search
      search_rut = search.gsub(/[.-]/, "")
      search_array = search.gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').split(' ')
      search_array2 = []
      search_array.each do |item|
        if item.length > 2
          search_array2.push('%'+item+'%')
        end
      end
      clients1 = where(company_id: company_id).where('first_name ILIKE ANY ( array[:s] )', :s => search_array2).where('last_name ILIKE ANY ( array[:s] )', :s => search_array2).pluck(:id).uniq
      clients2 = where(company_id: company_id).where("CONCAT(unaccent(first_name), ' ', unaccent(last_name)) ILIKE unaccent(:s) OR unaccent(first_name) ILIKE unaccent(:s) OR unaccent(last_name) ILIKE unaccent(:s) OR unaccent(record) ILIKE unaccent(:t) OR unaccent(email) ILIKE unaccent(:t) OR replace(replace(identification_number, '.', ''), '-', '') ILIKE :r", :s => "%#{search}%", :r => "%#{search_rut}%", :t => "%#{search_raw}%").pluck(:id).uniq
      where(id: (clients1 + clients2).uniq)
    else
      all
    end
  end

  def self.filter_location(locations)
    if !locations.blank?
      where(id: Booking.where(location_id: Location.find(locations)).select(:client_id))
    else
      all
    end
  end

  def self.filter_provider(providers)
    if !providers.blank?
      where(service_provider_id: ServiceProvider.find(providers)).select(:client_id))
    else
      all
    end
  end

  def self.filter_service(services)
    if !services.blank?
      where(id: Booking.where(service_id: Service.find(services)).select(:client_id))
    else
      all
    end
  end

  def self.filter_gender(gender)
    if !gender.blank?
      where(gender: gender)
    else
      all
    end
  end

  def self.filter_birthdate(from, to)
    if option && (["0","1","2"].include? option)
      if option == "0"
        where(birth_day: Time.now.day, birth_month: Time.now.month)
      elsif option == "1"
        weekStart = Time.now.beginning_of_week
        weekEnd = Time.now.end_of_week
        if weekStart.month == weekEnd.month
          where(birth_day: weekStart.day..weekEnd.day, birth_month: weekStart.month)
        else
          monthEnd = weekEnd.end_of_month.day
          where('(birth_month = ? AND birth_day BETWEEN ? AND ?) OR (birth_month = ? AND birth_day BETWEEN ? AND ?)', weekStart.month, weekStart.day, monthEnd, weekEnd.month, 1, weekEnd.day)
        end
      elsif option == "2"
        where(birth_month: Time.now.month)
      end
    else
      all
    end
  end

  def self.filter_status(statuses)
    if !statuses.blank?
      where(id: Booking.where(status_id: Status.find(statuses)).select(:client_id))
    else
      all
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

  def self.import(file, company_id)
    allowed_attributes = ["email", "first_name", "last_name", "identification_number", "phone", "address", "district", "city", "age", "gender", "birth_day", "birth_month", "birth_year", "record", "second_phone"]
    spreadsheet = open_spreadsheet(file)
    if !spreadsheet.nil?
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]

        if row["email"] && row["email"] != ""
          row["email"] = row["email"].to_s
        end

        if row["first_name"] && row["first_name"] != ""
          row["first_name"] = row["first_name"].to_s
        end

        if row["last_name"] && row["last_name"] != ""
          row["last_name"] = row["last_name"].to_s
        end

        if row["phone"] && row["phone"] != ""
          row["phone"] = row["phone"].to_s.chomp('.0')
        end

        if row["address"] && row["address"] != ""
          row["address"] = row["address"].to_s
        end

        if row["district"] && row["district"] != ""
          row["district"] = row["district"].to_s
        end

        if row["city"] && row["city"] != ""
          row["city"] = row["city"].to_s
        end

        if row["age"] && row["age"] != ""
          row["age"] = row["age"].to_i
        end

        if row["gender"] && row["gender"] != ""
          row["gender"] = row["gender"].to_i
        end

        if row["birth_day"] && row["birth_day"] != ""
          row["birth_day"] = row["birth_day"].to_i
        end

        if row["birth_month"] && row["birth_month"] != ""
          row["birth_month"] = row["birth_month"].to_i
        end

        if row["birth_year"] && row["birth_year"] != ""
          row["birth_year"] = row["birth_year"].to_i
        end

        if row["record"] && row["record"] != ""
          row["record"] = row["record"].to_s.chomp('.0')
        end

        if row["second_phone"] && row["second_phone"] != ""
          row["second_phone"] = row["second_phone"].to_s.chomp('.0')
        end

        if row["identification_number"] && row["identification_number"] != ""

          cRut = row["identification_number"].to_s.gsub(/[\.\-]/, "")
          if cRut.length == 0
            row["identification_number"] = ''
          elsif cRut.length == 1
            row["identification_number"] = ''
          else
            cDv = cRut.split('')[cRut.length - 1]
            cRut = cRut[0..cRut.length - 2]
            if cDv && cRut
              rutF = ''
              while cRut.length > 3 do
                rutF = "." + cRut[(cRut.length - 3)..cRut.length] + rutF
                cRut = cRut[0..cRut.length - 4]
              end
              row["identification_number"] = cRut + rutF + "-" + cDv
            else
              row["identification_number"] = ''
            end
          end
        end

        if row["identification_number"] && row["identification_number"] != ""
          rut = row["identification_number"].to_s
          if rut.length < 8
            row["identification_number"] = ''
          else
            cRut = rut.gsub(/[\.\-]/, "")
            suma = 0
            cDv = cRut.split('')[cRut.length - 1]
            cRut = cRut[0..cRut.length - 2]
            mul = 2
            for i  in (cRut.length - 1).downto(0) do
              suma = suma + cRut.split('')[i].to_i * mul
              if mul == 7
                mul = 2
              else
                mul += 1
              end
            end
            res = suma % 11
            if res==1
              dvr = 'k'
            elsif res==0
              dvr = '0'
            else
              dvi = 11-res
              dvr = dvi.to_s
            end
            if dvr != cDv.downcase
              row["identification_number"] = ''
            end
          end
        end

        if row["identification_number"] && row["identification_number"] != "" && Client.where(identification_number: row["identification_number"], company_id: company_id).count > 0
          client = Client.where(identification_number: row["identification_number"], company_id: company_id).first
        elsif row["email"] && row["email"] != "" && Client.where(email: row["email"], company_id: company_id).count > 0
          client = Client.where(email: row["email"], company_id: company_id).first
        elsif row["first_name"] && row["first_name"] != "" && row["last_name"] && row["last_name"] != "" && Client.where(first_name: row["first_name"], last_name: row["last_name"], company_id: company_id).count > 0
          client = Client.where(first_name: row["first_name"], last_name: row["last_name"], company_id: company_id).first
        else
          client = Client.new
        end

        client.attributes = row.to_hash.select { |k,v| allowed_attributes.include? k }
        if company_id
          client.company_id = company_id
        end
        client.save
      end
      message = "Clientes importados exitosamente."
    else
      message = "Error en el archivo de importación, archivo inválido o lista vacía."
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, file_warning: :ignore)
    when ".xls" then Roo::Excel.new(file.path, file_warning: :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, file_warning: :ignore)
    end
  end
end
