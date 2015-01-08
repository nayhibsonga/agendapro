class Client < ActiveRecord::Base
  belongs_to :company

  has_many :client_comments, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validate :client_mail_uniqueness, :client_identification_uniqueness

  after_update :client_notification

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
          Booking.where('bookings.start >= ?', Time.now - 4.hours).where(client_id: self.id).each do |booking|
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

  def client_mail_uniqueness
    Client.where(company_id: self.company_id).each do |client|
      if self.email && self.email != "" && client != self && client.email != "" && self.email == client.email
        errors.add(:base, "No se pueden crear dos clientes con el mismo email.")
      end
    end
  end

  def client_identification_uniqueness
    Client.where(company_id: self.company_id).each do |client|
      if self.identification_number && self.identification_number != "" && client != self && client.identification_number != "" && self.identification_number == client.identification_number
        errors.add(:base, "No se pueden crear dos clientes con el mismo RUT.")
      end
    end
  end

  def self.search(search)
    if search
      search_rut = search.gsub(/[.-]/, "")
      where ["CONCAT(first_name, ' ', last_name) ILIKE :s OR email ILIKE :s OR first_name ILIKE :s OR last_name ILIKE :s OR replace(replace(identification_number, '.', ''), '-', '') ILIKE :r", :s => "%#{search}%", :r => "%#{search_rut}%"]
    else
      all
    end
  end
  def self.filter_location(location)
    if location && (location != '')
      where(id: Booking.where(location_id: location).pluck(:client_id))
    else
      all
    end
  end
  def self.filter_provider(provider)
    if provider && (provider != '')
      where(id: Booking.where(service_provider_id: provider).pluck(:client_id))
    else
      all
    end
  end
  def self.filter_service(service)
    if service && (service != '')
      where(id: Booking.where(service_id: service).pluck(:client_id))
    else
      all
    end
  end
  def self.filter_gender(gender)
    if gender && gender != ''
      if gender != "0"
        where(:gender => gender)
      else
        where('gender != ? and gender != ? or gender IS NULL', 1, 2)
      end
    else
      all
    end
  end
  def self.filter_birthdate(option)
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
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end
  def self.import(file, company_id)
    allowed_attributes = ["email", "first_name", "last_name", "identification_number", "phone", "address", "district", "city", "age", "gender", "birth_day", "birth_month", "birth_year"]
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

          row["phone"] = row["phone"].to_i.to_s
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
