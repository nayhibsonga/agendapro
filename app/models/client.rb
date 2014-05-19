class Client < ActiveRecord::Base
  belongs_to :company

  has_many :client_comments

  validates_uniqueness_of :email, :scope => :company_id

  validates :email, :first_name, :last_name, :presence => true

  def self.search(search)
    if search
      where ["CONCAT(first_name, ' ', last_name) ILIKE :s OR email ILIKE :s OR first_name ILIKE :s OR last_name ILIKE :s", :s => "%#{search}%"]
    else
      all
    end
  end
  def self.filter_location(location)
    if location && (location != '')
      where(email: Booking.where(location_id: location).pluck(:email))
    else
      all
    end
  end
  def self.filter_provider(provider)
    if provider && (provider != '')
      where(email: Booking.where(service_provider_id: provider).pluck(:email))
    else
      all
    end
  end
  def self.filter_service(service)
    if service && (service != '')
      where(email: Booking.where(service_id: service).pluck(:email))
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
        puts row
        client = Client.find_by_email(row["email"]) || Client.new
        client.attributes = row.to_hash.select { |k,v| allowed_attributes.include? k }
        if company_id
          client.company_id = company_id
        end
        client.save!
      end
      message = "Clientes importados correctamente."
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
