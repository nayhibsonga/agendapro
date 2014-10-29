class Client < ActiveRecord::Base
  belongs_to :company

  has_many :client_comments, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validate :client_mail_uniqueness, :client_identification_uniqueness

  after_update :client_notification

  def client_notification
    if changed_attributes['email']
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

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def valid_email
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
    if gender && (gender != '')
      where(:gender => gender)
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
        puts weekStart.to_s
        weekEnd = Time.now.end_of_week
        puts weekEnd.to_s
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
    allowed_attributes = ["email", "first_name", "last_name", "phone", "address", "district", "city", "age", "gender", "birth_day", "birth_month", "birth_year"]
    spreadsheet = open_spreadsheet(file)
    if !spreadsheet.nil?
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        if row["email"] && row["email"] != ""
          client = Client.find_by_email(row["email"]) || Client.new
        else
          client = Client.new
        end
        client.attributes = row.to_hash.select { |k,v| allowed_attributes.include? k }
        if company_id
          client.company_id = company_id
        end
        client.save!
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
