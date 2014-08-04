class Client < ActiveRecord::Base
  belongs_to :company

  has_many :client_comments, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validate :client_mail_uniqueness

  after_save :client_notification

  def client_notification
    valid = false
    atpos = self.email.index("@")
    dotpos = self.email.rindex(".")
    if atpos && dotpos
      if (atpos < 1) || (dotpos < atpos+2) || (dotpos+2 >= self.email.length)
        valid = false
      end
      valid = true
    end
    valid = false
    puts valid
    if !valid
      Booking.where('bookings.start >= ?', Time.now - 5.hours).where(client_id: self.id).each do |booking|
        booking.send_mail = false
        booking.save
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
      if self.email != "" && client != self && client.email != "" && self.email == client.email
        errors.add(:base, "No se pueden crear dos clientes con el mismo email.")
      end
    end
  end

  def self.search(search)
    if search
      where ["CONCAT(first_name, ' ', last_name) ILIKE :s OR email ILIKE :s OR first_name ILIKE :s OR last_name ILIKE :s", :s => "%#{search}%"]
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
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end
  def self.import(file, company_id)
    allowed_attributes = ["email", "first_name", "last_name", "phone", "address", "district", "city", "age", "gender", "birth_date"]
    spreadsheet = open_spreadsheet(file)
    if !spreadsheet.nil?
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        client = Client.find_by_email(row["email"]) || Client.new
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
