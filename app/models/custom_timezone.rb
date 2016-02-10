class CustomTimezone
  DEFAULT_TIMEZONE_NAME = 'CLT'
  DEFAULT_TIMEZONE_OFFSET = -3

  attr_accessor :name, :offset, :offseti

  def initialize(*args)
    @name = args.first || DEFAULT_TIMEZONE_NAME
    @offset = (args.second || DEFAULT_TIMEZONE_OFFSET).hours
    @offseti = args.second || DEFAULT_TIMEZONE_OFFSET
  end

  class << self
    def from_company(company)
      if company.present?
        CustomTimezone.new(company.country.timezone_name, company.country.timezone_offset)
      else
        CustomTimezone.new
      end
    end

    def from_booking_history(booking_history)
      entity = booking_history.user ||
               booking_history.staff_code ||
               booking_history.service_provider
      self.from_company(entity.company)
    end

    def from_clients(client_ids)
      countries = Country.where(id: Company.where(id: Client.where(id: client_ids).pluck(:company_id)).pluck(:country_id))
      country = countries.group_by{|i| i}.values.max_by(&:size).first
      CustomTimezone.new(country.timezone_name, country.timezone_offset)
    end

    def from_sales_cash(sales_cash)
      self.from_company(sales_cash.location.company)
    end

    def from_booking(booking)
      entity = booking.service_provider ||
               booking.service ||
               booking.location ||
               booking.client
      slef.from_company(entity.company)
    end

    def first_timezone
      country = Country.all.order(:timezone_offset).first
      CustomTimezone.new(country.timezone_name, country.timezone_offset)
    end

    def last_timezone
      country = Country.all.order(:timezone_offset).last
      CustomTimezone.new(country.timezone_name, country.timezone_offset)
    end
  end
end
