class Client < ActiveRecord::Base
  belongs_to :company

  has_many :client_comments

  validates_uniqueness_of :email, :scope => :company_id

  validates :email, :first_name, :last_name, :presence => true

  def self.search(search)
    if search
      where(['lower(email) LIKE lower(?) or lower(last_name) LIKE lower(?) or lower(first_name) LIKE lower(?)', "%#{search}%","%#{search}%","%#{search}%"])
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
end
